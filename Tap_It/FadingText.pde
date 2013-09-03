public class FadingText {
  
  /** A simple class that can instantiate fading text
   and keep track of its lifetime, like a toast in the android os **/

  private int age;
  private float x;
  private float y;
  private String text;
  private color textColor;

  private final int LIFE = 75;
  private float textSize = .09; // * width 


  public FadingText(color textColor, String text, float x, float y) {
    textSize *= width;

    age = 0; 
    this.text = text;
    this.x = x;
    this.y = y;
    this.textColor = textColor;
  }

  public boolean isDead() {
    return (age >= LIFE);
  }

  public void displayAndUpdate() {
    textAlign(CENTER, CENTER); // center text for added or subtracted time toasts

    age++;
    fill(textColor, 255.0 * sq(sq(1 - age / (float) LIFE)));
    textSize(textSize);
    text(text, x, y);

    textAlign(LEFT, BASELINE); // return textAlign to normal
  }
}

