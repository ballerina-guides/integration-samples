package integration.samples.springboot.reactive.socialmedia.sentiment;

public class Probability {
    private double neg;
    private double neutral;
    private double pos;

    public double getNeg() {
        return neg;
    }

    public void setNeg(double neg) {
        this.neg = neg;
    }

    public double getNeutral() {
        return neutral;
    }

    public void setNeutral(double neutral) {
        this.neutral = neutral;
    }

    public double getPos() {
        return pos;
    }

    public void setPos(double pos) {
        this.pos = pos;
    }
}
