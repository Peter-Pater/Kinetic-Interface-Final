import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class kinect_final extends PApplet {

ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<Shoot_ball> shoot_balls = new ArrayList<Shoot_ball>();
ArrayList<Targets> targets = new ArrayList<Targets>();
Boolean first = true;

public void setup() {
    
    background(0);
    targets.add(new Targets(100, 100, 50, color(0, 255, 0)));
}

public void draw() {
    background(0);
    targets.get(0).display();
    joints_ball_control();
    shoot_ball_control();
}

public void joints_ball_control(){
    if (mouseX > 0 && mouseY > 0){
        if (first) {
            balls.add(new Ball(mouseX, mouseY, 20, color(255, 0, 0), 50));
            first = false;
        }
        for (Ball b : balls) {
            PVector p = new PVector(mouseX, mouseY);
            b.display(p);
        }
    }
}

public void shoot_ball_control(){
    for (Shoot_ball shoot_ball : shoot_balls){
        shoot_ball.move();
        shoot_ball.collision(targets);
        shoot_ball.fadeOut();
    }
    // delete shoot_balls
    for (int i = shoot_balls.size() - 1; i >= 0; i--){
        Shoot_ball shoot_ball = shoot_balls.get(i);
        if (shoot_ball.fade < 0){
            shoot_balls.remove(i);
        }
    }
}
class Ball {
    int d;
    int c;
    PVector pos, vel;
    float th;
    int STATE;
    Ball(float _x, float _y, int _d, int _c, float _th) {
        pos = new PVector(_x, _y);
        d = _d;
        c = _c;
        th = _th;
        STATE = 0; //0: vel below threshold, can shoot out balls; 1: vel above threshold, balls already out
    }
    public void display(PVector newpos) {
        fill(c);
        ellipse(newpos.x, newpos.y, d, d);
        this.detect(newpos);
    }
    public void detect(PVector newpos) {
        PVector p = newpos.copy();
        PVector vel = PVector.sub(p, pos);
        println(vel);
        if (vel.mag() >= th && STATE == 0) {
            //println("pos:"+pos);
            //println("new:"+p);
            //println(PVector.sub(p, pos).mag());
            //println("shoot");
            PVector newvel = PVector.div(vel,3);
            Shoot_ball shoot_ball = new Shoot_ball(newpos.copy(), newvel, d, c);
            shoot_balls.add(shoot_ball);
            STATE = 1;
        } else if (vel.mag() < th && STATE == 1) {
            STATE = 0;
        }
        pos = newpos.copy();
    }
}
class Shoot_ball{
    PVector vpos;
    PVector vacc;
    float d; // diameter
    int c;
    int fade = 255;
    int hit_count = 3;

    Shoot_ball(PVector vpos, PVector vacc, int d, int c){
        this.vpos = vpos;
        this.vacc = vacc;
        this.d = d;
        this.c = c;
    }

    public void move(){
        fill(red(c), green(c), blue(c), fade);
        ellipse(this.vpos.x, this.vpos.y, d, d);
        this.vpos.add(this.vacc);
    }
//Targets[] targets
    public void collision(ArrayList<Targets> targets){
        // collision against wall
        float nextX = vpos.x + vacc.x;
        float nextY = vpos.y + vacc.y;
        if (nextX < 0 || nextX > width){
            this.vacc.x = -this.vacc.x;
            this.hit_count -= 1;
        }
        if (nextY < 0 || nextY > height){
            this.vacc.y = -this.vacc.y;
            this.hit_count -= 1;
        }
        // collision against targets
        for (Targets target: targets){
            if (target.vpos.dist(this.vpos) < this.d/2 + target.d/2){
                this.vacc.x = -this.vacc.x;
                this.vacc.y = -this.vacc.y;
            }
        }
    }

    public void fadeOut(){
        if (hit_count <= 0){
            fade -= 5;
        }
    }
}
class Targets{

    PVector vpos;
    int d;
    int c;

    Targets(int x, int y, int d, int c){
        this.vpos = new PVector(x, y);
        this.d = d;
        this.c = c;
    }

    public void display(){
        fill(c);
        ellipse(this.vpos.x, this.vpos.y, d, d);
    }
    
    public void playSound() {
        
    }
}
    public void settings() {  size(800, 600); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "kinect_final" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
