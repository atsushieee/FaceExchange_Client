#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"

#define UDP_PORT 8338


class testApp : public ofxiPhoneApp {
	
public:
	void setup();
	void update();
	void draw();
    void initialize();
    
    ofxOscReceiver	receiver;
    
    // 位置
    ofVec2f position;
    float scale;
    // 傾き
    ofVec3f orientation;
    
    ofMesh mesh;
    ofImage faceImage;

};


