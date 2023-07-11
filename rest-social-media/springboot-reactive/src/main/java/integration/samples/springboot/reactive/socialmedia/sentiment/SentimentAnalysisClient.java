package integration.samples.springboot.reactive.socialmedia.sentiment;

import reactor.core.publisher.Mono;

public interface SentimentAnalysisClient {

    Mono<Sentiment> retrieveSentiment(String content);
}
