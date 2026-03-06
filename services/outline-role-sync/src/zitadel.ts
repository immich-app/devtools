interface ZitadelUser {
  userId: string;
  username: string;
}

interface ZitadelUserGrant {
  id: string;
  projectId: string;
  roleKeys: string[];
}

export class ZitadelClient {
  constructor(
    private baseUrl: string,
    private token: string,
  ) {}

  private async request<T>(method: string, path: string, body?: Record<string, unknown>): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      method,
      headers: {
        "Authorization": `Bearer ${this.token}`,
        "Content-Type": "application/json",
      },
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Zitadel API error ${response.status} on ${path}: ${text}`);
    }

    return await response.json() as T;
  }

  async findUserByEmail(email: string): Promise<ZitadelUser | null> {
    const result = await this.request<{ result?: ZitadelUser[] }>(
      "POST",
      "/v2/users",
      {
        queries: [
          {
            emailQuery: {
              emailAddress: email,
              method: "TEXT_QUERY_METHOD_EQUALS",
            },
          },
        ],
      },
    );

    const users = result.result ?? [];
    return users.length > 0 ? users[0] : null;
  }

  async getUserGrants(userId: string, projectId: string): Promise<string[]> {
    const result = await this.request<{ result?: ZitadelUserGrant[] }>(
      "POST",
      `/management/v1/users/${userId}/grants/_search`,
      {
        queries: [
          {
            projectIdQuery: {
              projectId,
            },
          },
        ],
      },
    );

    const grants = result.result ?? [];
    return grants.flatMap((grant) => grant.roleKeys);
  }
}
