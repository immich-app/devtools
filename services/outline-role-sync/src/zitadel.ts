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

  private async request<T>(
    method: string,
    path: string,
    body?: Record<string, unknown>,
  ): Promise<T> {
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
      throw new Error(
        `Zitadel API error ${response.status} on ${path}: ${text}`,
      );
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
    // The per-user path (/users/{userId}/grants/_search) 405s; the grants search
    // lives at /users/grants/_search filtered by user, then narrowed to the
    // project client-side.
    const result = await this.request<{ result?: ZitadelUserGrant[] }>(
      "POST",
      `/management/v1/users/grants/_search`,
      {
        queries: [
          {
            userIdQuery: {
              userId,
            },
          },
        ],
      },
    );

    const grants = (result.result ?? []).filter((grant) =>
      grant.projectId === projectId
    );
    return grants.flatMap((grant) => grant.roleKeys);
  }
}
