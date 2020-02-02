import keystoneMap.*;
Keystone ks;
CornerPinSurface surface;
boolean isCalibrating = true;

void initScreens() {
  ks = new Keystone(this);
  
  surface = ks.createQuadPinSurface(width, height, 20);
  canvas = createGraphics(width, height, P3D);
}

void saveKeystone() {
  ks.save("data/keystone/keystone.xml");
}

void loadKeystone() {
  ks.load("data/keystone/keystone.xml");
}

void renderScreens() {
  surface.render(canvas);
}

void toggleCalibration() {
  isCalibrating = !isCalibrating;
  if (isCalibrating) ks.startCalibration();
  else ks.stopCalibration();
}
