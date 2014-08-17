import javax.swing.JFrame;

int hLeds = 160;
int vLeds = 30;

previewWindow mApplet;

public class previewWindow extends PApplet {
  public void setup() {
    background(0);    
    noLoop();
  }

  public void draw() {
  }
  
  public void plotPixel(int x, int y, int c) {
    fill(c);
    ellipse(x, y, 4, 4);
  }
  
  public int sketchWidth() {
    return displayWidth/4;
  }

  public int sketchHeight() {
    return displayHeight/4;
  }
}

public class PreviewWindowFrame extends JFrame {
  public PreviewWindowFrame() {
    setBounds(10, 10, displayWidth/2, displayHeight/2);
    mApplet = new previewWindow();
    add(mApplet);
    mApplet.init();
    //show();
    setVisible(true);
  }
  
  public void plotPixel(float x, float y, int c) {
    mApplet.plotPixel(int(x * 2.0), int(y * 2.0), c);
  }
  
  public void redraw() {
    mApplet.redraw();
  }
}

void updatePreview() {
  loadPixels();
  for(float x = 0; x < width; x += (width/((float)hLeds))) {
    for(float y = 0; y < height; y += (height/((float)vLeds))) {
      int ix, iy;
      ix = int(x);
      iy = int(y);
      mPreviewWindowFrame.plotPixel(x, y, pixels[iy*width+ix]);
    }
  }
  mPreviewWindowFrame.redraw();
  
}

