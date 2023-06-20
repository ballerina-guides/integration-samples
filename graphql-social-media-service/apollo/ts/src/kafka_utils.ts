import { Consumer, Kafka, KafkaConfig } from "kafkajs";
import { Post } from "./types/post";
import { EachMessagePayload } from "kafkajs";
import config from "config";

interface NewPosts {
  newPosts: Post;
}

const POST_TOPIC = "post-created";
const { port }: { port: number } = config.get("kafka");
const kafkaConfig: KafkaConfig = { brokers: [`localhost:${port}`] };
const kafka = new Kafka(kafkaConfig);

export const publishPost = async (post: Post) => {
  const producer = kafka.producer();
  await producer.connect();
  await producer.send({
    topic: POST_TOPIC,
    messages: [{ value: JSON.stringify(post) }],
  });
  await producer.disconnect();
};

export const subscribePost = (groupId: string): AsyncIterator<NewPosts> => {
  return new PostSubscriber(groupId);
};

class PostSubscriber implements AsyncIterator<NewPosts> {
  private postsQueue: Post[] = [];
  private pullQueue = [];
  private consumer: Consumer;
  private isSubscribed = false;

  constructor(groupId: string) {
    this.consumer = kafka.consumer({ groupId });
  }

  public async next(): Promise<IteratorResult<NewPosts>> {
    if (!this.isSubscribed) {
      await this.subscribe();
    }
    return new Promise((resolve) => {
      if (this.postsQueue.length !== 0) {
        const value: NewPosts = { newPosts: this.postsQueue.shift() };
        resolve({ value, done: false });
        return;
      }
      this.pullQueue.push(resolve);
    });
  }

  private async subscribe() {
    await this.consumer.connect();
    await this.consumer.subscribe({ topic: POST_TOPIC });
    this.consumer.run({
      eachMessage: async ({
        topic,
        partition,
        message,
      }: EachMessagePayload) => {
        const post: Post = JSON.parse(message.value?.toString());
        this.addPost(post);
      },
    });
    this.isSubscribed = true;
  }

  private addPost(post: Post) {
    if (this.pullQueue.length !== 0) {
      const value: NewPosts = { newPosts: post };
      this.pullQueue.shift()({ value, done: false });
      return;
    }
    this.postsQueue.push(post);
  }

  public [Symbol.asyncIterator]() {
    return this;
  }

  public async return(): Promise<IteratorResult<NewPosts>> {
    this.consumer.disconnect();
    return { value: undefined, done: true };
  }
}
