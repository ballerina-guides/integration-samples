package integration.samples.springboot.reactive.socialmedia.sentiment;

public class Sentiment {
    private Probability probability;
    private String label;

    public Probability getProbability() {
        return probability;
    }

    public void setProbability(Probability probability) {
        this.probability = probability;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }
}
