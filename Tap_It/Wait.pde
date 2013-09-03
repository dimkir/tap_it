public class Wait {
  /*
This class has a time limit which is passed to the constructor, and a timer 
   which is started when the class is constructed. An instance of a class can
   be queried to see if its allotted time is up. The class can also display and update
   itself to show how much of its allotted time remains */

  private int timeLimit;
  private Timer timer;

  private float barWidth = .55; // * width
  private float barHeight = .075; // * height
  private float barX = .5;
  private float barY = .5;
  private float roundedFraction = .5;
  private float textSize = .08; // * height

  private final color TEXTCOLOR = color(255);
  private color barColor = color(255, 255, 0);
  private color BG = color(0);

  /******** CONSTRUCTOR, pass timeLimit in milliseconds ********/
  public Wait (int timeLimit) {
    barWidth *= width;
    barHeight *= height;
    barX *= width;
    barY *= height;
    textSize *= height;

    this.timeLimit = timeLimit;
    timer = new Timer(timeLimit);
    timer.start();
  }


  // to be called in the draw loop
  public void displayAndUpdate() {
    background(BG);
    rectMode(CORNER);

    // draw waiting text
    textAlign(CENTER, BASELINE);
    textSize(textSize);
    fill(TEXTCOLOR);
    text("Ready?", barX, barY - barHeight * 1.5);
    textAlign(LEFT, BASELINE);

    // calculate bar width based on elapsed time, draw bar
    float bw = (min(timeLimit, timer.elapsedTime()) / (float) timeLimit) * barWidth; 
    fill(barColor);
    rect(barX - barWidth / 2.0, barY - barHeight / 2.0, bw, barHeight, barHeight * roundedFraction);
  }

  // query Wait to see if its allotted time is up
  public boolean timeIsUp() {
    return timer.timeIsUp();
  }
}

