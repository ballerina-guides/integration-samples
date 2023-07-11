package integration.samples.springboot.reactive.socialmedia.sentiment;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;

@Service
public class SentimentAnalysisClientImpl implements SentimentAnalysisClient {
    private final WebClient sentimentClient;

    @Value("${sentiment-api.maxRetryAttempts}")
    private int maxRetryAttempts;
    @Value("${sentiment-api.waitDuration}")
    private int waitDuration;

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
                .bodyToMono(Sentiment.class)
                .retryWhen(Retry.fixedDelay(maxRetryAttempts, Duration.ofSeconds(waitDuration)));
    }
}
