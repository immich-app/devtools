export interface OutlineUser {
  id: string;
  name: string;
  email: string;
  role: string;
  isSuspended: boolean;
}

interface OutlineGroup {
  id: string;
  name: string;
}

interface OutlineGroupMembership {
  id: string;
  name: string;
  memberCount: number;
}

export class OutlineClient {
  constructor(
    private baseUrl: string,
    private apiToken: string,
  ) {}

  private async request<T>(path: string, body: Record<string, unknown> = {}): Promise<T> {
    const response = await fetch(`${this.baseUrl}/api${path}`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${this.apiToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Outline API error ${response.status} on ${path}: ${text}`);
    }

    return (await response.json() as { data: T }).data;
  }

  async getUserInfo(userId: string): Promise<OutlineUser> {
    return await this.request<OutlineUser>("/users.info", { id: userId });
  }

  async getUserGroups(userId: string): Promise<OutlineGroupMembership[]> {
    const result = await this.request<{ groups: OutlineGroupMembership[] }>("/groups.list", {
      userId,
    });
    return result.groups;
  }

  async listAllGroups(): Promise<OutlineGroup[]> {
    const result = await this.request<{ groups: OutlineGroup[] }>("/groups.list", {});
    return result.groups;
  }

  async createGroup(name: string): Promise<OutlineGroup> {
    return await this.request<OutlineGroup>("/groups.create", { name });
  }

  async addUserToGroup(groupId: string, userId: string): Promise<void> {
    await this.request("/groups.add_user", { id: groupId, userId });
  }

  async removeUserFromGroup(groupId: string, userId: string): Promise<void> {
    await this.request("/groups.remove_user", { id: groupId, userId });
  }

  async updateUserRole(userId: string, role: "admin" | "member" | "viewer"): Promise<void> {
    await this.request("/users.update", { id: userId, role });
  }
}
