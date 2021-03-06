/**
 * An FFT object is used to convert an audio signal into its frequency domain representation. This representation
 * lets you see how much of each frequency is contained in an audio signal. Sometimes you might not want to 
 * work with the entire spectrum, so it's possible to have the FFT object calculate average frequency bands by 
 * simply averaging the values of adjacent frequency bands in the full spectrum. There are two different ways 
 * these can be calculated: <b>Linearly</b>, by grouping equal numbers of adjacent frequency bands, or 
 * <b>Logarithmically</b>, by grouping frequency bands by <i>octave</i>, which is more akin to how humans hear sound.
 * <br/>
 * This sketch illustrates the difference between viewing the full spectrum, 
 * linearly spaced averaged bands, and logarithmically spaced averaged bands.
 * <p>
 * From top to bottom:
 * <ul>
 *  <li>The full spectrum.</li>
 *  <li>The spectrum grouped into 30 linearly spaced averages.</li>
 *  <li>The spectrum grouped logarithmically into 10 octaves, each split into 3 bands.</li>
 * </ul>
 *
 * Moving the mouse across the sketch will highlight a band in each spectrum and display what the center 
 * frequency of that band is. The averaged bands are drawn so that they line up with full spectrum bands they 
 * are averages of. In this way, you can clearly see how logarithmic averages differ from linear averages.
 * <p>
 * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
 */

import ddf.minim.analysis.*;
import ddf.minim.*;
import peasy.*;

PeasyCam cam;
Minim minim;  
AudioInput in;

FFT fftLin;
FFT fftLog;

float height3;
float height23;
float spectrumScale = 100; // initial value
float maxPeak = 0;
long peakTime = 0;
final static long TIMESINCELASTPEAK = (1000000000 * 15); // 15 seconds
PFont font;

int hLeds = 160;
int vLeds = 40;

boolean sketchFullScreen() {
  return true;
}

public int sketchWidth() {
  return displayWidth;
}

public int sketchHeight() {
  return displayHeight;
}

public String sketchRenderer() {
  return P3D;
}

void setup()
{
  //size(hLeds * 6, vLeds * 12, P3D);
  cam = new PeasyCam(this, width/2.0, height/2.0, 0, 2000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(50000);
  colorMode(HSB, 360, 100, 100, 100);

  minim = new Minim(this);
  in = minim.getLineIn();

  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  fftLin = new FFT( in.bufferSize(), in.sampleRate() );

  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages( 30 );

  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( in.bufferSize(), in.sampleRate() );

  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, 6);

  rectMode(CORNERS);
  background(0);
}

float rot = 0;
float rotIncr = 0.4;
float ROTMAX = 360;

void draw()
{
  if (rot >= ROTMAX) {
    rot = 0.0;
  }
  rot += rotIncr;

  PImage c = get();
  image(c, 0, 1);

  fill(0, 0, 0, 2);
  rect(0, 0, width, height);

  textSize( 18 );

  float centerFrequency = 0;
  float currentPeak = 0;

  // perform a forward FFT on the samples in jingle's mix buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
  fftLin.forward( in.mix );
  fftLog.forward( in.mix );

  // no more outline, we'll be doing filled rectangles from now
  strokeWeight(2);

  float numRects = (fftLog.avgSize()/2.0);
  // draw the linear averages
  {
    // since linear averages group equal numbers of adjacent frequency bands
    // we can simply precalculate how many pixel wide each average's 
    // rectangle should be.
    int w = int(width/numRects);
    PShape s = createShape(GROUP);
    for (int i = 0; i < numRects; i++)
    {
      //float amp = (float)Math.log10((fftLog.getAvg(i)));
      //float amp = (float)Math.sqrt((fftLog.getAvg(i)));
      float amp = (float)Math.pow((fftLog.getAvg(i)), 0.4);
      //float amp = fftLog.getAvg(i);
      //fill((i * (100.0/numRects) + rot) % 100, 100, 100);
      color clr = color((i * (ROTMAX/numRects) + rot) % ROTMAX, 100, 100);
      // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
      //rect(i*w, height, i*w + w, height - (amp*spectrumScale));
      drawEqBand(i*w, height, i*w +w, height - (amp*spectrumScale), clr, s);
      if (amp > currentPeak) {
        currentPeak =  amp;
      }
    }
    pushMatrix();
    translate(0, 0, abs(100*sin(radians(rot))));
    rotateZ(radians(rot));
    shape(s);
    rotate(HALF_PI);
    shape(s);
    rotate(HALF_PI);
    shape(s);
    rotate(HALF_PI);
    shape(s);
    popMatrix();

    if (currentPeak > maxPeak || ((System.nanoTime() - peakTime) > TIMESINCELASTPEAK )) {
      maxPeak = currentPeak;
      peakTime = System.nanoTime();
    }

    // now we have a reasonable peak, let's figure out what the scale should be
    spectrumScale = height / maxPeak;
  }
}

void drawEqBand(float x1, float y1, float x2, float y2, color c, PShape parent) {
  PShape s = createShape();
  s.setStroke(c);
  s.setStrokeWeight(2);
  s.beginShape();
  s.vertex(x1, y1);
  s.vertex(x1, y2);
  s.vertex(x2, y2);
  s.vertex(x2, y1);
  s.vertex(x1, y1);
  s.endShape();
  parent.addChild(s);
}

