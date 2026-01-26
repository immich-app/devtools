import {
  addAssetsToAlbum,
  createAlbum,
  createUserAdmin,
  getAllAlbums,
  init,
  searchAssets,
  searchSmart,
  searchUsersAdmin,
  updateAlbumInfo,
  updateUserAdmin,
  type UserAdminCreateDto,
} from '@immich/sdk';
import { DateTime } from 'luxon';

const baseUrl = process.argv[2] || process.env.IMMICH_BASE_URL;
const apiKey = process.argv[3] || process.env.IMMICH_API_KEY;
if (!baseUrl || !apiKey) {
  console.log('Usage: npx src/seed-demo.ts <baseUrl> <apiKey>');
  process.exit(1);
}

const defaultPassword = process.env.IMMICH_DEFAULT_PASSWORD || 'password';

init({ baseUrl, apiKey });

const upsertUsers = async () => {
  const users: UserAdminCreateDto[] = ['Alex', 'Zack', 'Jason', 'Mich', 'Alice', 'Bob'].map((name) => ({
    name,
    email: `${name.toLowerCase()}@immich.app`,
    password: defaultPassword,
    shouldChangePassword: false,
  }));

  const response = await searchUsersAdmin({});

  for (const user of users) {
    const existing = response.find(({ email }) => user.email === email);
    if (existing) {
      console.log(`Updated user ${user.name}`);
      await updateUserAdmin({
        id: existing.id,
        userAdminUpdateDto: { name: user.name, password: user.password, shouldChangePassword: false },
      });
      continue;
    }

    console.log(`Creating user ${user.name} with email ${user.email}`);
    await createUserAdmin({ userAdminCreateDto: user });
  }
};

const getAlbumName = (date: DateTime) => `${date.year}'${date.toFormat('LL')} - ${date.toFormat('MMMM')}'s Pictures`;
const getAlbumDescription = (date: DateTime) => `Pictures and videos for the month of ${date.toFormat('MMMM')}`;

type AlbumItem = {
  id?: string;
  assetIds: string[];
  name: string;
  description: string;
};

const upsertAlbums = async (newAlbums: AlbumItem[]) => {
  const albumsMap: Record<string, AlbumItem> = {};
  for (const album of newAlbums) {
    albumsMap[album.name] = album;
  }

  const albums = await getAllAlbums({});
  for (const album of albums) {
    if (albumsMap[album.albumName]) {
      albumsMap[album.albumName].id = album.id;
    }
  }

  for (const { name, description, assetIds } of Object.values(albumsMap)) {
    const albumId = albumsMap[name].id;
    if (albumId) {
      console.log(`Updating ${name}`);
      await updateAlbumInfo({ id: albumId, updateAlbumDto: { description } });
      await addAssetsToAlbum({ id: albumId, bulkIdsDto: { ids: assetIds } });
    } else {
      console.log(`Creating ${name} with ${assetIds.length} assets`);
      await createAlbum({ createAlbumDto: { albumName: name, assetIds, description } });
    }
  }
};

const createMonthAlbums = async () => {
  const albumsMap: Record<string, AlbumItem> = {};

  let page = 1;
  let count = 0;

  while (true) {
    const { assets } = await searchAssets({ metadataSearchDto: { page, size: 1000 } });
    for (const asset of assets.items) {
      const assetDate = DateTime.fromISO(asset.localDateTime, { zone: 'utc' });
      const albumName = getAlbumName(assetDate);
      if (!albumsMap[albumName]) {
        albumsMap[albumName] = {
          name: albumName,
          description: getAlbumDescription(assetDate),
          assetIds: [],
        };
      }

      albumsMap[albumName].assetIds.push(asset.id);
    }

    count += assets.count;
    console.log(`Found ${count} assets`);
    page++;

    if (!assets.nextPage) {
      break;
    }
  }

  await upsertAlbums(Object.values(albumsMap));
};

const createQueryAlbum = async () => {
  const queries = [
    'Cats',
    'Dogs',
    'Birds',
    'Music',
    'Food',
    'Travel',
    'Family',
    'Friends',
    'Camping',
    'Hiking in the mountains',
    'Playing at the beach',
    'Airplanes',
    'Grassy fields',
    'Sunset at the beach',
    'Cool cars',
    'Red cars',
    'Blue cars',
    'Green cars',
    'Yellow cars',
    'Blue horses',
    'Mountains',
    'City',
    'Cities at night',
    'Nature',
    'Street food',
    'Sunset',
    'Sunrise',
    'Party',
    'Wedding',
    'Birthday',
    'Holiday',
  ];
  const albums: AlbumItem[] = [];

  for (const query of queries) {
    const { assets } = await searchSmart({ smartSearchDto: { page: 1, size: 500, query } });

    console.log(`Found ${assets.count} assets for '${query}'`);
    const assetIds = assets.items.map(({ id }) => id);

    if (assetIds.length === 0) {
      continue;
    }

    albums.push({
      name: query,
      description: `Auto-generated album based on the query "${query}"`,
      assetIds,
    });
  }

  await upsertAlbums(albums);
};

const main = async () => {
  await upsertUsers();
  await createMonthAlbums();
  await createQueryAlbum();
};

main()
  .then(() => {
    console.log('Done');
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
