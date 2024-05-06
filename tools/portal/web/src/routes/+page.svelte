<script lang="ts">
	import Button from '$lib/components/ui/button/button.svelte';
	import * as Card from '$lib/components/ui/card';
	import * as Table from '$lib/components/ui/table';

	const getInstances = async () => {
		const result = await fetch('http://localhost:3000/api/preview');
		return result.json();
	};
</script>

<div class="flex flex-wrap justify-center gap-4 p-10">
	{#await getInstances() then instances}
		{#each instances as instance}
			<Card.Root>
				<Card.Header>
					<Card.Title>{instance.name}</Card.Title>
					<Card.Description>Card Description</Card.Description>
				</Card.Header>
				<Card.Content>
					<p>Tag: {instance.spec.immich.tag}</p>
					<p>Status: {instance.status}</p>
				</Card.Content>
			</Card.Root>
		{/each}
		<Card.Root class="flex w-[150px] items-center justify-center">
			<Button class="w-20">+</Button>
		</Card.Root>
		<div class="w-[50%]">
			<Table.Root>
				<Table.Caption>Instances</Table.Caption>
				<Table.Header>
					<Table.Row>
						<Table.Head class="w-[100px]">Name</Table.Head>
						<Table.Head>Tag</Table.Head>
						<Table.Head>Status</Table.Head>
					</Table.Row>
				</Table.Header>
				<Table.Body>
					{#each instances as instance}
						<Table.Row>
							<Table.Cell class="font-medium">{instance.name}</Table.Cell>
							<Table.Cell>{instance.spec.immich.tag}</Table.Cell>
							<Table.Cell>{instance.status}</Table.Cell>
						</Table.Row>
					{/each}
					<Table.Row>
						<Table.Cell colspan={3} class="text-center"><Button class="w-40">+</Button></Table.Cell>
					</Table.Row>
				</Table.Body>
			</Table.Root>
		</div>
	{/await}
</div>
