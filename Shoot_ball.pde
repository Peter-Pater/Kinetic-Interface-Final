class Shoot_ball {
    PVector vpos;
    PVector vacc;
    float d; // diameter
    color c;
    int fade = 200;
    int hit_count = 2;
    float vacc_mag;

    Shoot_ball(PVector vpos, PVector vacc, int d, color c) {
        this.vpos = vpos;
        this.vacc = vacc;
        this.d = d;
        this.c = c;
        this.vacc_mag = vacc.mag();
    }

    void move() {
        noStroke();
        fill(red(c), green(c), blue(c), fade);
        ellipse(this.vpos.x, this.vpos.y, d, d);
        this.vpos.add(this.vacc);
    }
    //Targets[] targets
    void collision(ArrayList<Target> targets) {
        // collision against wall
        float nextX = vpos.x + vacc.x;
        float nextY = vpos.y + vacc.y;
        if (nextX < 0 || nextX > width) {
            this.vacc.x = -this.vacc.x;
            this.hit_count -= 1;
            HITS += 1;
        }
        if (nextY < 0 || nextY > height) {
            this.vacc.y = -this.vacc.y;
            this.hit_count -= 1;
            HITS += 1;
        }
        // collision against targets
        for (Target target : targets) {
            if (target.vpos.dist(this.vpos) < this.d/2 + target.d/2) {
                //this.vacc.x = -this.vacc.x;
                //this.vacc.y = -this.vacc.y;
                target.get_hit = true;
                this.hit_count -= 1;
                calculate_bounce(target.vpos);
                while (target.vpos.dist(this.vpos) < this.d/2 + target.d/2) {
                    this.vpos.add(this.vacc);
                }
                target.playSound();
            }
        }
    }

    void fadeOut() {
        if (hit_count <= 0) {
            fade -= 5;
        }
    }

    void calculate_bounce(PVector target_vpos) {
        PVector bounce_vector = this.vpos.copy().sub(target_vpos);
        bounce_vector = bounce_vector.copy().normalize().mult(abs(this.vacc.dot(bounce_vector) / bounce_vector.mag()));
        this.vacc.add(bounce_vector.mult(2));
        this.vacc.normalize();
        this.vacc.mult(vacc_mag);
        //this.vacc = bounce_vector;
    }
}
