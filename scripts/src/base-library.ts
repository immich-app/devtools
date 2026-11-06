import { getQueue, QueueName, uploadAsset } from '@immich/sdk';
import { ExifTool } from 'exiftool-vendored';
import { find } from 'geo-tz';
import { DateTime } from 'luxon';
import { execFileSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { copyFile, mkdir, readdir, readFile, rename, rm } from 'node:fs/promises';
import { join } from 'node:path';
import { setTimeout } from 'node:timers/promises';

const datasetUrl =
  'https://huggingface.co/datasets/nlphuji/flickr30k/resolve/2b239befc81b6e3f035ce6bd52f5f4d60f5625f7/flickr30k-images.zip';
const timelineStart = DateTime.fromISO('2010-01-01', { zone: 'utc' });
const timelineDays = 16 * 365;
const concurrency = 8;

type Coordinates = { latitude: number; longitude: number };
type Place = Coordinates & { zone: string };
type Session = { start: DateTime; center: Coordinates; size: number; gps: boolean };
type Photo = { file: string; takenAt: DateTime; position?: Coordinates };

const random = (min: number, max: number) => min + Math.random() * (max - min);
const randomInt = (min: number, max: number) => Math.floor(random(min, max + 1));

const randomPlace = (): Place => {
  while (true) {
    const latitude = random(-56, 72);
    const longitude = random(-180, 180);
    const [zone] = find(latitude, longitude);
    // the open ocean only has Etc/GMT±N zones
    if (!zone.startsWith('Etc/')) {
      return { latitude, longitude, zone };
    }
  }
};

const nearby = ({ latitude, longitude }: Coordinates, km: number): Coordinates => {
  const angle = Math.random() * 2 * Math.PI;
  const distance = km * Math.random();
  return {
    latitude: latitude + (distance * Math.cos(angle)) / 111,
    longitude: longitude + (distance * Math.sin(angle)) / (111 * Math.cos((latitude * Math.PI) / 180)),
  };
};

/** Lays out a timeline of photo sessions: a few trips a year, and everyday life around a home that moves twice. */
const planSessions = (total: number) => {
  const homes = [randomPlace(), randomPlace(), randomPlace()];
  const homeOn = (day: number) => homes[Math.floor((day * homes.length) / timelineDays)];
  const sessions: Session[] = [];
  const tripDays = new Set<number>();

  const addSessions = (day: number, place: Place, radius: number, count: number, size: [number, number]) => {
    const date = timelineStart.plus({ days: day });
    for (let i = 0; i < count; i++) {
      sessions.push({
        start: DateTime.fromObject({ year: date.year, month: date.month, day: date.day }, { zone: place.zone }).plus({
          minutes: randomInt(8 * 60, 21 * 60),
        }),
        center: nearby(place, radius),
        size: randomInt(...size),
        gps: Math.random() < 0.8,
      });
    }
  };

  for (let trip = 0; trip < (timelineDays / 365) * 4; trip++) {
    const length = randomInt(2, 10);
    const first = randomInt(1, timelineDays - length - 1);
    if (Array.from({ length: length + 2 }, (_, i) => first - 1 + i).some((day) => tripDays.has(day))) {
      continue;
    }

    const destination = randomPlace();
    for (let day = first; day < first + length; day++) {
      tripDays.add(day);
      addSessions(day, destination, 5, randomInt(1, 4), [3, 15]);
    }
  }

  let planned = sessions.reduce((sum, { size }) => sum + size, 0);
  while (planned < total) {
    const day = randomInt(0, timelineDays - 1);
    const weekend = timelineStart.plus({ days: day }).weekday >= 6;
    if (tripDays.has(day) || (!weekend && Math.random() < 0.6)) {
      continue;
    }

    addSessions(day, homeOn(day), Math.random() < 0.5 ? 0.3 : 5, 1, [1, 8]);
    planned += sessions.at(-1)!.size;
  }

  return sessions.sort((a, b) => a.start.toMillis() - b.start.toMillis());
};

const planPhotos = (files: string[]) => {
  const photos: Photo[] = [];
  for (const { start, center, size, gps } of planSessions(files.length)) {
    let takenAt = start;
    let position = center;
    for (let i = 0; i < size && photos.length < files.length; i++) {
      photos.push({ file: files[photos.length], takenAt, position: gps ? position : undefined });
      takenAt = takenAt.plus({ seconds: randomInt(5, 300) });
      position = nearby(position, 0.05);
    }
  }
  return photos;
};

const forEachLimit = async <T>(items: T[], fn: (item: T, index: number) => Promise<void>) => {
  let next = 0;
  const worker = async () => {
    while (next < items.length) {
      const index = next++;
      await fn(items[index], index);
    }
  };
  await Promise.all(Array.from({ length: concurrency }, worker));
};

const download = async (dataDir: string) => {
  const imageDir = join(dataDir, 'flickr30k-images');
  if (!existsSync(imageDir)) {
    const zip = join(dataDir, 'flickr30k-images.zip');
    const extractDir = join(dataDir, 'extracting');
    await mkdir(dataDir, { recursive: true });
    execFileSync('curl', ['-fL', '-o', zip, datasetUrl], { stdio: 'inherit' });
    execFileSync('unzip', ['-q', '-o', zip, 'flickr30k-images/*', '-d', extractDir], { stdio: 'inherit' });
    await rename(join(extractDir, 'flickr30k-images'), imageDir);
    await rm(extractDir, { recursive: true });
    await rm(zip);
  }
  return imageDir;
};

/** Strips each image's metadata (keeping camera make/model) and writes the planned date and location. */
const writeLibrary = async (imageDir: string, libraryDir: string) => {
  const files = (await readdir(imageDir)).filter((file) => file.endsWith('.jpg')).sort();
  const photos = planPhotos(files);
  const partialDir = `${libraryDir}.partial`;
  await rm(partialDir, { recursive: true, force: true });
  await mkdir(partialDir, { recursive: true });

  const exiftool = new ExifTool({ maxProcs: concurrency });
  try {
    await forEachLimit(photos, async ({ file, takenAt, position }, index) => {
      const target = join(partialDir, file);
      await copyFile(join(imageDir, file), target);
      const gps = position ? [`-GPSLatitude*=${position.latitude}`, `-GPSLongitude*=${position.longitude}`] : [];
      await exiftool.write(
        target,
        {},
        {
          writeArgs: [
            ...['-all=', '-tagsFromFile', '@', '-ICC_Profile', '-Orientation', '-Make', '-Model'],
            `-AllDates=${takenAt.toFormat('yyyy:MM:dd HH:mm:ss')}`,
            `-OffsetTime*=${takenAt.toFormat('ZZ')}`,
            ...gps,
            '-overwrite_original',
          ],
        },
      );
      if ((index + 1) % 5000 === 0) {
        console.log(`Prepared ${index + 1}/${photos.length} files`);
      }
    });
  } finally {
    await exiftool.end();
  }

  await rename(partialDir, libraryDir);
};

// Smart search is the last (and slowest) step after upload, so once it's done the album steps have the extracted
// dates and embeddings they need. Faces, OCR etc. can finish in the background.
const waitForSmartSearch = async () => {
  let idleChecks = 0;
  while (idleChecks < 3) {
    await setTimeout(10_000);
    const { active, waiting, delayed } = (await getQueue({ name: QueueName.SmartSearch })).statistics;
    idleChecks = active + waiting + delayed === 0 ? idleChecks + 1 : 0;
    if (idleChecks === 0) {
      console.log(`Waiting for smart search: ${active + waiting + delayed} remaining`);
    }
  }
};

/** Uploads Flickr30k as the library of a person who travels a few times a year. */
export const seedBaseLibrary = async (dataDir: string) => {
  const imageDir = await download(dataDir);
  const libraryDir = join(dataDir, 'library');
  if (!existsSync(libraryDir)) {
    await writeLibrary(imageDir, libraryDir);
  }

  const files = await readdir(libraryDir);
  const now = new Date().toISOString();
  await forEachLimit(files, async (file, index) => {
    const assetData = new File([await readFile(join(libraryDir, file))], file);
    await uploadAsset({ assetMediaCreateDto: { assetData, fileCreatedAt: now, fileModifiedAt: now } });
    if ((index + 1) % 1000 === 0) {
      console.log(`Uploaded ${index + 1}/${files.length}`);
    }
  });

  await waitForSmartSearch();
};
