PlantFile[] beautyFiles;
float[] beautyScales = {0.78, 0.78, .95};
boolean[] beautyFlipped = {false, true, false};
float[] beautyRot = {-30, 0, -40};
PVector[] beautySnaps = {new PVector(108, 82), new PVector(3, 47), new PVector(76, 109)};


void initBeauty() {  
  beautyFiles = new PlantFile[3];
  for (int i = 0; i < beautyFiles.length; i++) {
    beautyFiles[i] = new PlantFile("beauty/leaves/" + i + ".svg", beautyFlipped[i], beautySnaps[i].x, beautySnaps[i].y, beautyScales[i], beautyRot[i]);
  }
}

class Beauty extends Plant {

  //ArrayList<BeautyLeaf> leaves;

  Beauty(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Beauty(PVector loc, float age, int code) {
    super(loc, age, code);
    //leaves = new ArrayList<BeautyLeaf>();
    hasLeaves = true;
    leafSpacing = 20;
  }

  void display(PGraphics s) {
    //s.stroke(col);
    s.pushMatrix();
    s.translate(x, y, z);
    //s.rotateX(radians((-groundRot)));
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);

    numBranch = 0;
    totLen = leafSpacing;
    currentLen = leafSpacing;

    s.stroke(0);
    s.fill(col);
    stem(s, plantHeight*growthScaler, 0, age, stemStroke);
    //leaves(s);
    s.popMatrix();

    col = color(#57ED66);
  }

  void leaf(int segment, PGraphics s) {
    int numleaves = round(plantHeight*growthScaler/ leafSpacing);
    if (segment <= numleaves) {
      float leafScale = map(segment, 0, 5, .6, .2)*plantHeight;
      leafScale = constrain(leafScale, 0.1, 1.0);
      beautyFiles[1].display(0, 0, 0, leafScale, false, s);
      beautyFiles[1].display(0, 0, 0, leafScale, true, s);
      if (isFlowering) berry(s, leafScale);
    }
  }

  void berry(PGraphics s, float leafScale) {
    s.fill(235, 0, 255);
    s.stroke(255);
    float a = constrain(age, 0, 1.1);
    float berryAge = map(a, bloomAge, 1.0, 0, 1.0);
    float berrySize = leafScale*20*berryAge;
    int berrySpacings[][] = {{0, 0}, {-15, 13}, {7, 12}, {-9, -10}, {4, -6}};
    s.pushMatrix();
    s.translate(0, 0, 1);
    for (int j = 0; j < berrySpacings.length; j++) {
      s.ellipse(berrySpacings[j][0]*leafScale, berrySpacings[j][1]*leafScale, berrySize, berrySize);
    }
    s.popMatrix();
  }

  @Override
    void flower(PGraphics s, float stemage) {
    // nada
  }
}
