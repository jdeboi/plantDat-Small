import keystoneMap.*;
Keystone ks;
CornerPinSurface surface;
boolean isCalibrating = true;

void initScreens(int w, int h) {
  ks = new Keystone(this);
  
  surface = ks.createQuadPinSurface(w, h, 20);
  canvas = createGraphics(w, h, P3D);
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
