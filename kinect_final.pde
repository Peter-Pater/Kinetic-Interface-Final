import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;

ControlP5 cp5;

KinectPV2 kinect;

Minim minim;
AudioPlayer[] sounds = new AudioPlayer[6];

/////////
AudioPlayer[] bgm = new AudioPlayer[6];
String[] bgmName = {"C", "G", "Am", "F", "Dm", "Bb"};
int bgmCount = 0;
int playingCount = 0;
PImage bg;
/////////

Ball[] balls = new Ball[12];
ArrayList<Shoot_ball> shoot_balls = new ArrayList<Shoot_ball>();
ArrayList<Target> targets = new ArrayList<Target>();
Boolean first = true;

PVector[] hands = new PVector[12];
int depthLow = 1000;
int depthHigh = 2500;

int th = 75;

int HITS;

PImage depthImg;
boolean isin_range = false;

color[] c = {color(222, 142, 255), color(234, 79, 85), color(111, 71, 127), 
    color(142, 188, 255), color(153, 70, 114), color(218, 233, 255)};

void setup() {
    //size(800, 600);
    size(1920, 1080, P3D);
    //size(1920, 1080, P3D);

    kinect = new KinectPV2(this);

    //kinect.enableSkeletonColorMap(true);
    kinect.enableDepthMaskImg(true);
    kinect.enableSkeletonDepthMap(true);

    kinect.init();

    minim = new Minim(this); 
    minim = new Minim(this);
    for (int i = 0; i < 6; i++) {
        sounds[i] = minim.loadFile(str(i+1)+".wav");
        println(str(i+1)+".wav loaded");
    }

    for (int i = 0; i < 6; i++) {
        bgm[i] = minim.loadFile(bgmName[i]+".wav");
        println(bgmName[i]+".wav loaded");
    }

    bg = loadImage("background.jpg");

    for (int i = 0; i < 6; i++) {
        int r = width/4;
        float a = PI/3;
        int x = width/8;
        float posx = width/2 + r * cos(a * i) + x * cos(a * i)/abs(cos(a * i));
        float posy = height/2.5 + r * sin(a * i);
        if (i == 1 || i == 2) posy += 80;
        if (i == 4 || i == 5) posy += 100;
        targets.add(new Target(posx, posy, random(80, 120), c[i], sounds[i]));
    }

    for (int i = 0; i < balls.length; i++) {
        balls[i] = new Ball(0, 0, 25, color(255, 0, 0), th);
    }

    for (int i = 0; i < hands.length; i++) {
        hands[i] = new PVector(0, 0);
    }
    
    cp5 = new ControlP5(this);
  
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("th")
     .setPosition(100, 1000)
     .setRange(50,200)
     ;
}

void draw() {
    fill(255);
    textSize(30);
text("WAVE HANDS HARD AND FAST",width/2-250,40);
    pushMatrix();
    translate(width/2, height/2);
    imageMode(CENTER);
    rotate(frameCount * 0.001);
    tint(255, 80);
    image(bg, 0, 0, 1.5 * width, 1.5 * width);
    popMatrix();

    imageMode(CORNER);
    //image(kinect.getDepthMaskImage(), 448, 116, 1024, 848);

    if (!bgm[bgmCount].isPlaying() || bgmCount != playingCount) {
        bgm[bgmCount].rewind();
        bgm[bgmCount].play();
        playingCount = bgmCount;
    }

    int[] rawDepth = kinect.getRawDepthData();
    int w = KinectPV2.WIDTHDepth;
    int h = KinectPV2.HEIGHTDepth;
    int point_count = 0;
    
    for (Ball b : balls) {
        b.th = th;
    }

    for (int i = 0; i < rawDepth.length; i++) {
        int x = i % w;
        int y = floor(i / w);
        int depth = rawDepth[i];

        if (depth >= depthLow && depth <= depthHigh) {
            if (x % 3 == 0 && y % 3 == 0) {
                point_count ++;
                float pX = map(x, 0, 512, 448, 1472);
                float pY = map(y, 0, 424, 116, 964);
                float pZ = map(depth, 1, 4499, 500, -500);
                pushStyle();
                stroke(255, random(200, 255), 255);
                strokeWeight(5);
                point(pX, pY, pZ);
                popStyle();
            }
        }
    }

    if (point_count > 888) {
        isin_range = true;
    } else {
        isin_range = false;
    }
    //println(isin_range);
    //print(point_count);
    ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

    //individual JOINTS
    for (int i = 0; i < skeletonArray.size(); i++) {
        KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
        if (skeleton.isTracked()) {

            KJoint[] joints = skeleton.getJoints();

            color col  = skeleton.getIndexColor();
            fill(col);
            stroke(col);


            //draw different color for each hand state
            float[] left;
            float[] right;
            int depthIndex = floor(joints[KinectPV2.JointType_Head].getY()) * w + floor(joints[KinectPV2.JointType_Head].getX());

            right = drawHandState(joints[KinectPV2.JointType_HandRight]);

            left = drawHandState(joints[KinectPV2.JointType_HandLeft]);
            print(joints[KinectPV2.JointType_Head].getX());
            print(" ");
            print(joints[KinectPV2.JointType_Head].getY());
            println();
            //print(hands[2*i]);

            if (depthIndex >= 0 && depthIndex <= rawDepth.length) {
                if (rawDepth[depthIndex] <= depthHigh && rawDepth[depthIndex] >= depthLow) {
                    hands[2*i].set(right[0], right[1]);
                    hands[2*i+1].set(left[0], left[1]);
                }
            }
        }
    }

    //if (isin_range) {
    //    
    //}

    joints_ball_control();


    fill(255, 0, 0);
    text(frameRate, 50, 50);

    shoot_ball_control();
    //pushMatrix();
    //translate(0,0,200);
    target_display();
    //popMatrix();

    if (HITS > 100) {
        bgm[bgmCount].pause();
        bgmCount = (bgmCount+1)%6;
        println(bgmCount);
        HITS = 0;
    }
}

void target_display() {
    for (Target target : targets) {
        target.display();
    }
}

void joints_ball_control() {
    for (int i = 0; i < hands.length; i++) {
        if (hands[i].x > 0 && hands[i].y > 0) {
            balls[i].display(new PVector(hands[i].x, hands[i].y));
        }
    }
}


void shoot_ball_control() {
    for (Shoot_ball shoot_ball : shoot_balls) {
        shoot_ball.move();
        shoot_ball.collision(targets);
        shoot_ball.fadeOut();
    }
    // delete shoot_balls
    for (int i = shoot_balls.size() - 1; i >= 0; i--) {
        Shoot_ball shoot_ball = shoot_balls.get(i);
        if (shoot_ball.fade < 0) {
            shoot_balls.remove(i);
        }
    }
}

//draw a ellipse depending on the hand state
float[] drawHandState(KJoint joint) {
    float newX, newY, newZ;
    newX = map(joint.getX(), 0, 512, 448, 1472);
    newY = map(joint.getY(), 0, 424, 116, 964);
    newZ = joint.getZ();
    //noStroke();
    //handState(joint.getState());
    //pushMatrix();
    //translate(newX, newY, newZ);
    //ellipse(0, 0, 70, 70);
    //popMatrix();

    float[] returnValue = {newX, newY};
    return returnValue;
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */

//Depending on the hand state change the color
void handState(int handState) {
    switch(handState) {
    case KinectPV2.HandState_Open:
        fill(0, 255, 0);
        break;
    case KinectPV2.HandState_Closed:
        fill(255, 0, 0);
        break;
    case KinectPV2.HandState_Lasso:
        fill(0, 0, 255);
        break;
    case KinectPV2.HandState_NotTracked:
        fill(100, 100, 100);
        break;
    }
}


//void drawBody(KJoint[] joints) {
//drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
//drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
//drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
//drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
//drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
//drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
//drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
//drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

//// Right Arm
//drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
//drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
//drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
//drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
//drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

//// Left Arm
//drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
//drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
//drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
//drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
//drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

//// Right Leg
//drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
//drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
//drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

//// Left Leg
//drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
//drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
//drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

//Single joints
//drawJoint(joints, KinectPV2.JointType_HandTipLeft);
//drawJoint(joints, KinectPV2.JointType_HandTipRight);
//drawJoint(joints, KinectPV2.JointType_FootLeft);
//drawJoint(joints, KinectPV2.JointType_FootRight);

//drawJoint(joints, KinectPV2.JointType_ThumbLeft);
//drawJoint(joints, KinectPV2.JointType_ThumbRight);

//drawJoint(joints, KinectPV2.JointType_Head);
//}

//draw a single joint
//void drawJoint(KJoint[] joints, int jointType) {
//    float newX, newY, newZ;
//    newX = map(joints[jointType].getX(), 0, 512, 448, 1472);
//    newY = map(joints[jointType].getY(), 0, 424, 116, 964);
//    newZ = joints[jointType].getZ();

//    pushMatrix();
//    translate(newX, newY, newZ);
//    ellipse(0, 0, 25, 25);
//    popMatrix();
//}

////draw a bone from two joints
//void drawBone(KJoint[] joints, int jointType1, int jointType2) {
//    float newX, newY, newZ, newX1, newY1, newZ1;
//    newX = map(joints[jointType1].getX(), 0, 512, 448, 1472);
//    newY = map(joints[jointType1].getY(), 0, 424, 116, 964);
//    newZ = joints[jointType1].getZ();

//    newX1 = map(joints[jointType2].getX(), 0, 512, 448, 1472);
//    newY1 = map(joints[jointType2].getY(), 0, 424, 116, 964);
//    newZ1 = joints[jointType2].getZ();

//    pushMatrix();
//    translate(newX, newY, newZ);
//    ellipse(0, 0, 25, 25);
//    popMatrix();
//    translate(newX1, newY1, newZ1);
//}
