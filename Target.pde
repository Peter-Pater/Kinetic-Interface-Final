class Target {

    PVector vpos;
    float d;
    color c;
    float coe = random(-1, 1);
    AudioPlayer sound;

    boolean get_hit = false;
    float timeStamp;

    Target(float x, float y, float d, color c, AudioPlayer sound) {
        this.vpos = new PVector(x, y);
        this.d = d;
        this.c = c;
        this.sound = sound;
    }

    void display() {
        fill(c);
        noStroke();
        float dx = cos(frameCount * 0.08*coe) * 5 * coe;
        float dy = -cos(frameCount * 0.08*coe) * 5 * coe;
        if (get_hit) {
            glowingEllipse(this.vpos.x+dx, this.vpos.y+dy, 1.2 * d);
            if (millis() - timeStamp > 150) {
                get_hit = false;
            }
        } else {
            timeStamp = millis();

            glowingEllipse(this.vpos.x+dx, this.vpos.y+dy, d);
        }
    }

    void playSound() {
        this.sound.rewind();
        this.sound.play();
    }

    void glowingEllipse(float x, float y, float d) {
        float glowR = d/2*0.8;
        for (int i = 0; i <= floor(glowR); i++) {
            float glowA = map(i, 0, glowR, 1, 0);
            float alpha = map(sq(glowA), 0, 1, 0, 255);
            strokeWeight(5);
            stroke(this.c, alpha);
            noFill();
            ellipse(x, y, (d/2 - glowR+i)*2, (d/2 - glowR+i)*2);
        }
        fill(this.c);
        ellipse(x, y, (d/2 - glowR)*2, (d/2 - glowR)*2);
    }
}
