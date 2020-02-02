int rainLasts = 1*60*1000;
int sunLasts = 1*60*1000;
long lastRainTime = 0;


PImage houses;
PShape housesSvg;
PShape wires;
PShape skyline;
PShape backhouses;

PImage cement;
PShape[] concrete;


PImage plants[];

boolean isRaining = true;
boolean thunder = false;
boolean  thundering = false;
long lastThundering = 0;
long lastThunder = 0;
int thunderNum = 0;
long ranTime = 0;
int tTime = 20;

float windAngle = 0;
float windNoise = 0;


color startDayColor, midDayColor, endDayColor;


import ddf.minim.*;
Minim minim;
AudioPlayer thunderSound;
AudioPlayer rainSound;
AudioPlayer windSound;

boolean rainEnding = false;

void playSounds() {
  if (thundering) {
    if (!thunderSound.isPlaying()) thunderSound.play(0);
    rainSound.setGain(0);
    windSound.setGain(-100);
  }
  if (isRaining) {
    // this will work as long as the rain soundfile is longer than the time rain lasts
    if (!rainSound.isPlaying()) rainSound.play(0);
    if (millis() - lastRainTime > rainLasts - 4000) {
      rainSound.shiftGain(rainSound.getGain(), -100, 4000);
      windSound.setGain(-4);
    }
  }
}

void stop() {
  windSound.close();
  thunderSound.close();
  rainSound.close();
  minim.stop();
}



color getBackground() {
  if (thunder) {
    return color(255);
  }
  return getBackgroundHue();
}

color getBackgroundHue() {
  color c;
  long timeP = millis() - lastRainTime;
  if (timeP < rainLasts*.7) {
    c = color(50);
  } else if (timeP < rainLasts) {
    float per = map(timeP, rainLasts*.7, rainLasts, 0, 1);
    c = lerpColor(color(50), endDayColor, per);
  } else if (timeP < rainLasts + sunLasts *.7) {
    c = endDayColor;
  } else {
    float per = map(timeP, rainLasts + sunLasts *.7, rainLasts + sunLasts, 0, 1);
    c = lerpColor(endDayColor, color(50), per);
    //println("not raining but getting closer");
  }
  return c;
}

void checkThunder() {
  if (isRaining) {
    // if it's about to stop raining, let's just not thunder
    if ( millis() - lastRainTime > rainLasts - 7000) {
      thundering = false;
      thunder = false;
    } else if (!thundering) {
      if (millis() - lastThundering > ranTime) {
        thundering = true;
        lastThundering = millis();
      }
    } else if (thundering) {
      if (!thunder) {
        if (thunderNum == 0) {
          thunder = true;
          lastThunder = millis();
          thunderNum++;
          tTime += 50;
        } else if (millis() - lastThunder > 50) {
          thunder = true;
          lastThunder = millis();
        }
      } else if (thunder) {
        if (millis() - lastThunder > tTime) {
          lastThunder = millis();
          thunder = false;
          thunderNum++;
          if (thunderNum == 5) {
            thundering = false;
            thunderNum = 0;
            tTime = 20;
            lastThundering = millis();
            ranTime = int(random(8000, 16000));
          }
        }
      }
    }
  } else {
    thundering = false;
    thunder = false;
  }
}

void initBackground() {
  plantColor = color(#11BB7C);
  stemStroke = color(0, 50, 0);
  startDayColor = color(#BCF5FF);
  midDayColor = color(#FFB4EE);
  endDayColor = color(#6965D6);

  //houses = loadImage("images/houses.png");

  housesSvg = loadShape("images/houses2.svg");
  wires = loadShape("images/wires2.svg");
  skyline = loadShape("images/skyline2.svg");
  backhouses = loadShape("images/backhouses2.svg");


  minim = new Minim(this);
  thunderSound = minim.loadFile("sounds/thunderSound.mp3");
  rainSound = minim.loadFile("sounds/rainSound.mp3");
  windSound = minim.loadFile("sounds/windSound.mp3");
  windSound.loop();
}

void displayHouse(PGraphics s, int z ) {
  s.pushMatrix();

  float w = s.width*2.8;
  float down = -s.height*.75;
  //float factor = w/houses.width;
  //float h = houses.height*factor;



  displayCement(s, down*1.35, z*2-3);


  s.translate(-w*.3, down, z);
  s.pushMatrix();

  s.rotate(radians(0));
  //s.image(houses, 0, 0, w, h);
  s.translate(-400, -230);
  float factor = 1.5;
  s.translate(0, 0, -2);
  skyline.disableStyle();
  s.fill(lerpColor(getBackgroundHue(), color(255), .1));
  s.shape(skyline, 0, 0, skyline.width*factor, skyline.height*factor);
  s.translate(0, 0, .5);
  backhouses.disableStyle();
  s.fill(lerpColor(getBackgroundHue(), color(255), .3));
  s.shape(backhouses, 0, 0, backhouses.width*factor, backhouses.height*factor);
  s.translate(0, 0, .5);
  s.shape(wires, 0, 0, wires.width*factor, wires.height*factor);
  s.translate(0, 0, .5);
  s.shape(housesSvg, 0, 0, housesSvg.width*factor, housesSvg.height*factor);


  s.popMatrix();

  //s.pushMatrix();
  //s.translate(s.width*.6, 0);
  //s.rotate(radians(0));
  //s.image(shotgun2, 0, 0, w, h);
  //s.popMatrix();



  s.popMatrix();
}


void checkRain() {

  if (millis() - lastRainTime < rainLasts) {
    isRaining = true;
  } else {
    isRaining = false;
  }

  if (millis() - lastRainTime > rainLasts + sunLasts) {
    lastRainTime = millis();
  }
}

//void displaySky(PGraphics s) {
//  s.noStroke();
//  for (int i = 0; i < 5; i++) {
//    s.pushMatrix();
//    s.translate(-s.width*2 + i*s.width, -200, -800);
//    color c1 = color(#6965D6);
//    color c2 = color(#FFADFB);
//    color c3 = color(#FFDAAD);

//    float per = 0.6;
//    int screenH = int(s.height*2.5);
//    s.beginShape();
//    s.fill(c1);
//    s.vertex(0, 0);
//    s.vertex(s.width, 0);
//    s.fill(c2);
//    s.vertex(s.width, screenH*per);
//    s.vertex(0, screenH*per);
//    s.endShape();

//    s.beginShape();
//    s.fill(c2);
//    s.vertex(0, screenH*per);
//    s.vertex(s.width, screenH*per);
//    s.fill(c3);
//    s.vertex(s.width, screenH);
//    s.vertex(0, screenH);
//    s.endShape();
//    s.popMatrix();
//  }

//  displayHouse(s, -1300);
//}

void displayCement(PGraphics s, float y, int z) {
  int gradStarts = 450;
  s.pushMatrix();
  s.translate(-s.width*2, y, z);
  s.noStroke();
  //s.rotateX(radians(90));
  //s.fill(0);
  //s.textureWrap(REPEAT);
  //s.textureMode(NORMAL);
  s.beginShape();
  //s.texture(cement);
  s.fill(darkCementColor);
  s.vertex(-s.width, 0, 0, 0);
  float inc = 0;
  for (int i = -s.width; i <= s.width*6; i+= 50) {
    //s.fill((i+s.width)*1.0/(s.width*7) * 255);
    s.vertex(i, noise(inc += 0.05)*150, (i+s.width)*1.0/(s.width*7), 0);
  }
  s.fill(cementColor);
  s.vertex(s.width*6, gradStarts, 1, 0);
  //s.vertex(s.width*6, s.height*2, 1, 1);
  //s.vertex(-s.width, s.height*2, 0, 1);
  s.vertex(-s.width, gradStarts, 0, 0);
  s.endShape();
  s.rect(-s.width, gradStarts, s.width*7, s.height*4);
  s.popMatrix();
}



void initCement() {
  concrete = new PShape[4];
  for (int i = 1; i < 5; i++) {
    concrete[i-1] = loadShape("images/concrete/concrete" + i + ".svg");
  }
}

void displayCementBreaking(PGraphics s) {
  if (breakingNum > 0 && breakingNum < 5) {
    s.shape(concrete[breakingNum-1], 0, 0);
  }
}


Drop[] drops;
int dropIndex = 0;
long dropTime = 0;
long dropSpawnTime = 5;

void initDrops() {
  drops = new Drop[200];
  for (int i = 0; i < drops.length; i++) {
    drops[i] = new Drop();
  }
}

boolean getRaining() {
  if (millis() - lastRainTime < rainLasts) {
    return true;
  }
  return false;
}

void displayRain(PGraphics s) {
  if (isRaining) {
    //if (millis() - dropTime > dropSpawnTime) {
    //  drops[dropIndex].spawn();
    //  drops[dropIndex+1].spawn();
    //  drops[dropIndex+2].spawn();
    //  dropIndex+=3;
    //  if (dropIndex >= drops.length-3) dropIndex = 0;
    //  dropTime = millis();
    //}
    int amt = 1;
    if (millis() - lastRainTime > rainLasts *.8) amt = int(map(millis()-lastRainTime, rainLasts*.7, rainLasts, 1, 8));
    for (int i = 0; i < drops.length; i+=amt) {
      drops[i].fall(20);
      drops[i].display(s);
    }
  }
}

class Drop {
  int x, y, yMax, len;

  Drop() {
    x = int(random(width));
    y = int(random(-1000, 0));

    len = int(random(8, 20));
    yMax = int(map(len, 8, 20, height*.4, height));
  }

  void fall(int speed) {

    //if (y > -100) y += speed;
    //if (y > yMax) {
    //  y = -100;
    //}
    if (isRaining) {
      y += speed;
      if (y > yMax) {
        y = -100;
      }
    } else {
      if (y > -20) {
        y += speed;
        if (y > yMax) {
          y = -100;
        }
      }
    }
  }

  void spawn() {
    y = -20;
  }

  void display(PGraphics s) {
    s.stroke(200);
    int sw = int(map(len, 8, 20, 1, 4));
    s.strokeWeight(sw);
    s.fill(255);
    //ellipse(x, y, 100, 100);
    s.line(x, y, x, y-len);
  }
}

float waterY = 0;
void waterOff() {
  waterY = -150;
}
void setWater() {
  incSpawnedFloat();
  float lowestSea = -150;
  float maxs = 200;

  float maxSea = map(spawnedFloat, 0, MAX_SPAWNED, maxs, -120);
  maxSea = constrain(maxSea, -100, maxs);
  if (isRaining) {

    waterY = map(millis() - lastRainTime, 0, rainLasts, lowestSea, maxSea);
    waterY = constrain(waterY, lowestSea, maxSea);
  } else {
    if (millis() - lastRainTime >  rainLasts+sunLasts*.3) {
      waterY = map(millis() - lastRainTime, rainLasts+sunLasts*.3, rainLasts+sunLasts*.7, maxSea, lowestSea);
      waterY = constrain(waterY, lowestSea, maxSea);
    }
  }
}


void wind() {
  //float windForce = map(mouseX, 0, width, -PI/7, PI/7);
  float windForce = map(noise(0, flyingTerr), 0, 1, -PI/15, PI/15);
  //windAngle =  windForce + windForce/4 * 2*PI * sin(mouseX/1000.0);
  windAngle =  windForce + windForce/4 *sin(map(noise(0, flyingTerr), 0, 1, 0, width)/1000.0);
}
