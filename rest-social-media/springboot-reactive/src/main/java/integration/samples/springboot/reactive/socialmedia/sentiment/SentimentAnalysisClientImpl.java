package integration.samples.springboot.reactive.socialmedia.sentiment;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class SentimentAnalysisClientImpl implements SentimentAnalysisClient {
    private final WebClient sentimentClient;

    @Autowired
    public SentimentAnalysisClientImpl() {
        this.sentimentClient = WebClient.builder().baseUrl("http://localhost:8088").build();
    }

    @Override
    public Mono<Sentiment> retrieveSentiment(String content) {
        return sentimentClient.post()
                .uri("/text-processing/api/sentiment")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(BodyInserters.fromValue(content))
                .retrieve()
                .bodyToMono(Sentiment.class);
    }
}
