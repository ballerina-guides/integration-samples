export interface UserData {
  id: string;
  name: string;
  age: number;
}

export interface UsersResponse {
  users: UserData[];
}

export interface PostData {
  id: string;
  title: string;
  content: string;
}

export interface UserPosts {
  posts: PostData[];
}
