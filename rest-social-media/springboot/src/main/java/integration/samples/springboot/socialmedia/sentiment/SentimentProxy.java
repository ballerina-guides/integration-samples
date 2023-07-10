package integration.samples.springboot.socialmedia.sentiment;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@FeignClient(name="sentiment-api", url="localhost:8088")
public interface SentimentProxy {
    @RequestMapping(
            method = RequestMethod.POST,
            value = "/text-processing/api/sentiment",
            consumes = "application/x-www-form-urlencoded"
    )
    Sentiment retrieveSentiment(@RequestBody SentimentRequest sentimentRequest);
}
