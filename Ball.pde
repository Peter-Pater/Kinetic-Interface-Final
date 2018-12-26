class Ball {
    int d;
    color c;
    PVector pos, vel;
    float th;
    int STATE;
    boolean get_hit = false;
    //float timeStamp = 0;
    
    Ball(float _x, float _y, int _d, color _c, float _th) {
        pos = new PVector(_x, _y);
        d = _d;
        c = _c;
        th = _th;
        STATE = 0; //0: vel below threshold, can shoot out balls; 1: vel above threshold, balls already out
    }
    void display(PVector newpos) {
        //fill(c);
        //ellipse(newpos.x, newpos.y, d, d);
        this.detect(newpos);
    }
    void detect(PVector newpos) {
        PVector p = newpos.copy();
        PVector vel = PVector.sub(p, pos);
        if (vel.mag() >= th && STATE == 0) {
            //println("pos:"+pos);
            //println("new:"+p);
            //println(PVector.sub(p, pos).mag());
            //println("shoot");
            PVector newvel = PVector.div(vel,3);
            if (newvel.mag() > 15){
                newvel.normalize();
                newvel.mult(15);
            }
            Shoot_ball shoot_ball = new Shoot_ball(newpos.copy(), newvel, d, color(255));
            shoot_balls.add(shoot_ball);
            STATE = 1;
        } else if (vel.mag() < th && STATE == 1) {
            STATE = 0;
        }
        pos = newpos.copy();
    }
}
