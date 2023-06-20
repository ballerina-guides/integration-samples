import { Kafka } from "kafkajs";
import config from "config";
const POST_TOPIC = "post-created";
const { port } = config.get("kafka");
const kafkaConfig = { brokers: [`localhost:${port}`] };
const kafka = new Kafka(kafkaConfig);
export const publishPost = async (post) => {
    const producer = kafka.producer();
    await producer.connect();
    await producer.send({
        topic: POST_TOPIC,
        messages: [{ value: JSON.stringify(post) }],
    });
    await producer.disconnect();
};
export const subscribePost = (groupId) => {
    return new PostSubscriber(groupId);
};
class PostSubscriber {
    constructor(groupId) {
        this.postsQueue = [];
        this.pullQueue = [];
        this.isSubscribed = false;
        this.consumer = kafka.consumer({ groupId });
    }
    async next() {
        if (!this.isSubscribed) {
            await this.subscribe();
        }
        return new Promise((resolve) => {
            if (this.postsQueue.length !== 0) {
                const value = { newPosts: this.postsQueue.shift() };
                resolve({ value, done: false });
                return;
            }
            this.pullQueue.push(resolve);
        });
    }
    async subscribe() {
        await this.consumer.connect();
        await this.consumer.subscribe({ topic: POST_TOPIC });
        this.consumer.run({
            eachMessage: async ({ topic, partition, message, }) => {
                const post = JSON.parse(message.value?.toString());
                this.addPost(post);
            },
        });
        this.isSubscribed = true;
    }
    addPost(post) {
        if (this.pullQueue.length !== 0) {
            const value = { newPosts: post };
            this.pullQueue.shift()({ value, done: false });
            return;
        }
        this.postsQueue.push(post);
    }
    [Symbol.asyncIterator]() {
        return this;
    }
    async return() {
        this.consumer.disconnect();
        return { value: undefined, done: true };
    }
}
