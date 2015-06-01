import unlekker.mb2.geo.*;
import unlekker.mb2.util.*;
import ec.util.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
ArrayList<Float> recordings;
ArrayList<Float> datapoints;
ArrayList<UVertexList> lists;
UGeo geo;

void setup() {
  size(600, 600, OPENGL);
  minim = new Minim(this);
  UMB.setGraphics(this);
  geo = new UGeo();
  lists = new ArrayList<UVertexList>();
  recordings = new ArrayList<Float>();
  datapoints = new ArrayList<Float>();
  in = minim.getLineIn();
}

void draw() {
  background(0);
  translate(width/2, height/2);

  //float ry=map(width/2-mouseX, -width/2, width/2, PI, -PI);
  //rotateY(ry);  
  float rx = map(height/2-mouseY, -height/2, height/2, PI, -PI);
  rotateX(rx);
  
  geo.draw();
}
void keyPressed() {
  if (key == 'r') {
    for(int i = 0; i < in.bufferSize() - 1; i++){
      recordings.add(in.left.get(i));
    }
  }
}
void keyReleased() {
  if (key == 'c') {
    recordings = new ArrayList<Float>();
    datapoints = new ArrayList<Float>();
  }
  if (key == 'd') {
    ArrayList<Float> samples = new ArrayList<Float>();
    for (int i = 0; i < recordings.size(); i += 10) {
      samples.add(recordings.get(i));
    }
    
    float averageSize = 20.0;
    for (int i = 0; i < samples.size() - averageSize; i += averageSize) {
      float sum = 0;
      for (int j = 0; j < averageSize; j++) {
        sum += abs(samples.get(i + j));
      }
      float avg = sum / averageSize;
      datapoints.add(avg);
    }
    buildShape();
  }
  if (key == 's') {
    geo.writeSTL("test.stl");
  }
}

void buildShape() {
  println("Generating shape...");
  geo = new UGeo();

  // For each datapoint, generate a vertex list of a circle with
  //    a radius that uses that datapoint as a radius
  //    and add each list to an array
  float spacing = (height-100)/datapoints.size();
  for (int i = 0; i < datapoints.size(); i++) {
    UVertexList newList = generateCircleVerticesWithRadius(datapoints.get(i));
    newList.translate(0, i*spacing, 0);
    lists.add(newList);
  }
  
  // Connect lists in the array from 0-1, 1-2, 2-3, ..., (n-2)-(n-1)
  for (int i = 0; i < lists.size() - 1; i++) {
    UVertexList v1 = lists.get(i);
    UVertexList v2 = lists.get(i+1);
    geo.quadstrip(v1, v2);
  }
  
  geo.triangleFan(lists.get(lists.size() - 1));
  geo.triangleFan(lists.get(0));
  
  println(lists.get(0));
  println(lists.get(1));
  
  geo.center();
  println("Shape complete!");
  //geo.center().scale(0.5);
}

UVertexList generateCircleVerticesWithRadius(float rad) {
  int n = 6;
  UVertexList list = new UVertexList();
  float newRadius = map(rad, 0, 1, 10, width/2);
  for(int i=0; i<=n; i++) {
    float deg=map(i, 0, n, 0,180);
    newRadius = map(rad, 0, 1, 10, width/2);
    list.add(new UVertex(newRadius, 0, 0).rotY(radians(-deg)));
  }
  list.add(new UVertex(newRadius, 0, 0).rotY(0));
  return list;
}
