List<PVector> global_lines;
List<PVector> findCorners(PImage img) {
  
  // --- Entire Pipeline Displayed ---

  // 2) Hue/Brightness/Saturation Threshhold
  PImage result = thresholdHSB(img, hueMin, hueMax, saturationMin, saturationMax, brightnessMin, brightnessMax);

  // 3) Blob Detection
  result = findConnectedComponents(result, true);
  
  // 4) Blurring (assumes grayscale)
  result = convolute(result);

  // 5) Edge Detection
  result = scharr(result);

  // 6) Low brightness supression
  result = thresholdBrightness(result, 100);
  
  // 7) Hough transform
  List<PVector> lines = hough(result, nlines, regionRadius);
  global_lines = lines;
  // 8) Plot lines
  //plotLines(result, lines);

  // 9) Compute quad
  QuadGraph quadgraph = new QuadGraph();
  
  return quadgraph.findBestQuad(lines, img.width, img.height, img.width * img.height, 5000, false);
  
}

PVector computeRotation(List<PVector> quads){
  List<PVector> pointsHomogeneous = new ArrayList<PVector>();
  for(PVector point : quads){
    pointsHomogeneous.add(new PVector(point.x, point.y, 1)); 
  }
  PVector rotationRad = twoDThreeD.get3DRotations(pointsHomogeneous);
  
  //println("r_x = "+radToDeg(rotationRad.x)+"°, r_y = "+radToDeg(rotationRad.y)+"°, r_z = "+radToDeg(rotationRad.z)+"°"); 
  return new PVector(rotationRad.x, rotationRad.y, -rotationRad.z);
}

float radToDeg(float angle){
  return angle * 180 / PI;
}