#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
    // to secure the memory domain of the image
    faceImage.allocate(768, 1024, OF_IMAGE_COLOR);
    faceImage.loadImage("jiu.jpg");

    receiver.setup( UDP_PORT );
}



/**
 *  put in the information sent from a server
 *  initialization objects
 */
void testApp::initialize()
{
    // check for waiting messages
    while (receiver.hasWaitingMessages()) {
        // get the next message
        ofxOscMessage m;
        receiver.getNextMessage(&m);
        const char *address = m.getAddress().c_str();
//        std::cout << m.getAddress() << std::endl;
        if (strcmp(address, "/orientation") == 0) {
            float x = m.getArgAsFloat(0);
            float y = m.getArgAsFloat(1);
            float z = m.getArgAsFloat(2);
            orientation.set(x, y, z);
        } else if (strcmp(address, "/position") == 0) {
            float x = m.getArgAsFloat(0);
            float y = m.getArgAsFloat(1);
            position.set(x, y);
        } else if (strcmp(address, "/scale") == 0) {
            scale = m.getArgAsFloat(0);
        } else if (strcmp(address, "/vertices") == 0) {
            // create mesh based on a camera image
            int numOfArgs = m.getNumArgs();
            
            bool isFirst = mesh.getVertices().size() > 0 ? false : true;
            
            for (int i = 0; i < numOfArgs; i += 3) {
                float x = m.getArgAsFloat(i);
                float y = m.getArgAsFloat(i + 1);
                float z = m.getArgAsFloat(i + 2);
                ofVec3f vertex(x, y, z);
                ofVec2f vec2Tex(x,y);
                
                if (isFirst) {
                    mesh.setMode(OF_PRIMITIVE_TRIANGLES);
                    mesh.addVertex(vertex);
                    mesh.addTexCoord(vec2Tex);                
                }
                else {
                    mesh.setVertex(i / 3, vertex);
                    mesh.setTexCoord(i / 3, vec2Tex);                    
                    
                }
            }                 

        } else if (strcmp(address, "/triangleIndices") == 0) {
            
            int numOfArgs = m.getNumArgs();
            bool isFirst = mesh.getIndices().size() > 0 ? false : true;

            for (int i = 0; i < numOfArgs; i ++) {
                int indexType = m.getArgAsInt32(i);
                
                if (isFirst){                    
                    mesh.addIndex(indexType);                                    
                } else {
                    mesh.setIndex(i, indexType);            
                }
                
            }                
        }
    }
}

//--------------------------------------------------------------
void testApp::update(){

    // initialization objects
    initialize();
    
}

//--------------------------------------------------------------
void testApp::draw(){    
    
    ofSetColor(255);
    
    // cam.draw(0, 0);
    ofDrawBitmapString(ofToString((int) ofGetFrameRate()), 10, 20);
    
    // no-3D perspective
    ofSetupScreenOrtho(640, 480, OF_ORIENTATION_DEFAULT, true, -1000, 1000);
    
    // position,size, imclination of the face detected with camera
    ofPushMatrix();
    ofTranslate(position.x, position.y);
    ofScale(scale, scale, scale);
    ofRotateX(orientation.x * 45.0f);
    ofRotateY(orientation.y * 45.0f);
    ofRotateZ(orientation.z * 45.0f);
    
    // NOTE:create wireframe
//    mesh.drawWireframe();

 
    faceImage.getTextureReference().bind();
    mesh.draw();
    faceImage.getTextureReference().unbind();
    ofPopMatrix();
}
