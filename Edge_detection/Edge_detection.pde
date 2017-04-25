PImage img;
PImage imgCorrect;

HScrollbar thresholdBar1;
HScrollbar thresholdBar2;
HScrollbar thresholdBar3;

void settings() {
  size(1600, 600);
}
void setup() {
  img = loadImage("board1.jpg");
  imgCorrect = loadImage("board1Thresholded.bmp");
  thresholdBar1 = new HScrollbar(0, 580, 800, 20);
  thresholdBar2 = new HScrollbar(800, 540, 800, 20);
  thresholdBar3 = new HScrollbar(800, 580, 800, 20);
}
void draw() {
  background(color(0, 0, 0));
  
  //Brighness filtering imag
  float thresh = 255 * thresholdBar1.getPos();
  PImage imgB = thresholdBrightness(img, (int) thresh);
  image(imgB, 0, 0);

  //Hue filtering image
  float tLow = 255 * thresholdBar2.getPos();
  float tHigh = 255 * thresholdBar3.getPos();
  PImage imgHue = thresholdHue(img, (int) tLow, (int) tHigh);
  image(imgHue, img.width, 0);

  thresholdBar1.display();
  thresholdBar2.display();
  thresholdBar3.display();
  thresholdBar1.update();
  thresholdBar2.update();
  thresholdBar3.update();
  
  PImage imgFinal = thresholdHSB(img, 100, 200, 100, 255, 45, 100);
  println(imagesEqual(imgFinal, imgCorrect));

}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    color c = img.pixels[i];
    int value = (minB <= brightness(c) && brightness(c) <= maxB &&
                 minH <= hue(c) && hue(c) <= maxH &&
                 minS <= saturation(c) && saturation(c) <= maxS) ? 255 : 0;
    result.pixels[i] = color (value, value, value);
  }
  return result;
}

PImage thresholdHue(PImage img, int tLow, int tHigh) {
  // create a new, initially transparent, ’result’ image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    float hue = hue(img.pixels[i]);
    if (hue >= tLow && hue <= tHigh) {
      result.pixels[i] = color(img.pixels[i]);
    } else {
      result.pixels[i] = color(0, 0, 0);
    }
  }
  return result;
}

PImage thresholdBrightness(PImage img, int threshold) {
  // create a new, initially transparent, ’result’ image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i]) >= threshold) {
      result.pixels[i] = color(255, 255, 255);
    } else {
      result.pixels[i] = color(0, 0, 0);
    }
  }
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}