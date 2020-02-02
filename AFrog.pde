PlantFile[] frogLeaves;
PlantFile[] frogFlowers;

void initFrog() {
  frogFlowers = new PlantFile[3];
  float[] frogScales = {0.15, 0.2, .2};
  boolean[] frogFlipped = {false, false, false};
  float[] frogRot = {radians(0), radians(0), radians(0)};
  PVector[] frogSnaps = {new PVector(50, 50), new PVector(50, 80), new PVector(50, 100)};
  for (int i = 0; i < frogFlowers.length; i++) {
    frogFlowers[i] = new PlantFile("frog/flowers/" + i + ".svg", frogFlipped[i], frogSnaps[i].x, frogSnaps[i].y, frogScales[i], frogRot[i]);
  }

  frogLeaves = new PlantFile[2];
  frogLeaves[0] = new PlantFile("frog/leaves/" + 0 + ".svg", false, 80, 10, 0.3, radians(90));
  frogLeaves[1] = new PlantFile("frog/leaves/" + 1 + ".svg", false, 110, 70, 0.15, radians(90));
}

class Frog extends Plant {
  int numVines;
  Plant[] flowers;
  float startAng;
  int numFlowers;

  Frog(PVector loc, float age, int code) {
    super(loc, age, code);
    numVines = int(random(3, 6));
    flowers = new Plant[numVines];
    startAng = random(0, 360);
    col = color(#27711D);
  }

  void display(PGraphics s) {
    s.pushMatrix();
    s.translate(x, y, z);
    s.stroke(255);
    s.rotateX(radians(map(z, 0, -1400, -10, -40)));
    s.strokeWeight(10);
    for (int i = 0; i < numVines; i++) {
      float ang = map(i, 0, numVines-1, 260, 20);
      drawVine(s, ang+startAng, i);
    }
    s.popMatrix();
  }

  void drawVine(PGraphics s, float ang, int numVine) {


    s.pushMatrix();

    s.rotateY(-radians(ang));

    float x = 0;
    float z = 0;
    float a = 0;
    float j = ang;
    float len = map(age, 0, 1, 0, 70);
    int count = 0;
    //float len = 20;

    s.strokeWeight(2);
    s.noFill();
    s.stroke(col);

    s.pushMatrix();
    s.translate(0, 1, 0);
    s.beginShape();
    s.vertex(x, 0, z);

    // stem
    int segLen = 8;
    for (int i = 0; i<= len; i+= segLen) {
      //s.vertex(x, 0, z);
      a = map(noise(j+=1 + frameCount/5000.0), 0, 1, -60, 60);
      x += segLen * cos(radians(a));
      z += segLen * sin(radians(a));
      s.vertex(x, 0, z);


      if (i + segLen > len) {
        a = map(noise(j+=1 + frameCount/5000.0), 0, 1, -60, 60);
        float leftover = len - i;
        x += leftover * cos(radians(a));
        z += leftover * sin(radians(a));
        s.vertex(x, 0, z);
      }
    }
    s.endShape();
    s.popMatrix();

    // leaf
    a = 0;
    j = ang;
    x = 0;
    z = 0;
    for (int i = 0; i<= len; i+= segLen) {
      //s.vertex(x, 0, z);
      a = map(noise(j+=1 + frameCount/5000.0), 0, 1, -60, 60);
      x += segLen * cos(radians(a));
      z += segLen * sin(radians(a));
      int sb = int(map(ang, 260, 20, 2, 10));

      // middle flower on 1/3
      if (pID%3 == 0 && numVine == 0 && count == 0 ) {
        numFlowers++;
        float stalkLen = 100*plantHeight;
        flower(s, x, z, ang, stalkLen);
      }
      // rando flower
      if (count == (pID+numVine)%6 && numVine %3 == 0) {
        numFlowers++;
        float stalkLen = 100*map(plantHeight, 0, 1, -.1, 1);
        stalkLen = constrain(stalkLen, 0, 100*plantHeight);
        flower(s, x, z, ang, stalkLen);
      }
      if (count == (pID+numVine)%6+6 && numVine %2 == 0) {
        numFlowers++;
        float stalkLen = 100*map(plantHeight, 0, 1, -.6, 1);
        stalkLen = constrain(stalkLen, 0, 100*plantHeight);
        flower(s, x, z, ang, stalkLen);
      }

      //if (i % 4 == 0) leaf(s, x, z, 1);
      if (count > 0) {
        if (plantHeight <= .5) {
          //if (count/10 == 0) leaf(s, x, z, 0);
        } else {
          if (count%3 == 0) leaf(s, x, z, 0);
          //if (count%4 == 2) leaf(s, x, z, 0);
        }
      }
      if (i + segLen > len) {
        a = map(noise(j+=1 + frameCount/5000.0), 0, 1, -60, 60);
        float leftover = len - i;
        x += leftover * cos(radians(a));
        z += leftover * sin(radians(a));
        s.vertex(x, 0, z);
      }
      count++;
      //println(count, (pID+numVine)%4);
    }
    s.popMatrix();
  }

  void leaf(PGraphics s, float x, float z, int num) {
    s.pushMatrix();
    s.translate(x, 0, z);
    s.rotateX(radians(90));
    s.strokeWeight(1);
    s.fill(0, 255, 0);
    s.stroke(0);
    //s.ellipse(0, -5, 5, 10);
    //s.ellipse(0, 5, 5, 10);
    frogLeaves[0].display(0, 0, 0, plantHeight, false, s);

    s.popMatrix();
  }

  void flower(PGraphics s, float x, float z, float ang, float stalkLen) {
    float len = map(age, 0, 1, 0, 30);



    // curve stalk
    s.strokeWeight(3);
    s.noFill();
    s.stroke(col);
    float curveAmt = 130*plantHeight;
    s.beginShape();
    s.curveVertex(x-curveAmt, 0, z);
    s.curveVertex(x, 0, z);
    s.curveVertex(x+5, -stalkLen, z);
    s.curveVertex(x-curveAmt, -stalkLen, z);
    s.endShape();

    // leaves on stalk
    s.pushMatrix();
    s.translate(x, -stalkLen/8, z);
    //s.rotateX(radians(90));
    for (int i = 0; i < 3; i++) {
      s.translate(0, -stalkLen/4, 0);
      frogLeaves[0].display(15, 0, radians(90), plantHeight*map(i, 0, 3, .7, .3), false, s);
    }
    s.popMatrix();




    // bud
    s.pushMatrix();
    s.strokeWeight(1);
    s.fill(0, 255, 255);
    s.stroke(0);
    s.translate(x, -stalkLen, z);
    s.rotateY(radians(ang));
    if (isFlowering) {
      s.pushMatrix();
      frogFlowers[getFlowerIndex(age)].display(0, 0, 0, plantHeight, false, s);
      s.popMatrix();
    }
    s.popMatrix();
  }


  int getFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, frogFlowers.length));
    num = constrain(num, 0, frogFlowers.length-1);
    return num;
  }
}

class FrogFlower extends Plant {

  FrogFlower() {
    super(0, 0, 0);
  }

  void display() {

    ellipse(0, 0, 20, 20);
  }
}
