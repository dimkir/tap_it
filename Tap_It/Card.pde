public class Card {

  private int nSyms; // number of symbols per card, less than total nSyms for deck
  private int[] symIndices; // index of each symbol
  // there are SPC + (SPC - 1) ^ 2 distinct symbols and distinct cards in the deck

  private float x; // center of card
  private float y;
  private float theta = 0; // rotation angle of card
  private float omega = 0; // angular velocity of card

  private float sr; // symbol radius
  private float[] sx; // symbol position relative to the center of the card
  private float[] sy;
  private float[] sa;


  private float r; // radius of circular card
  private float borderWidth = .055; // * radius
  private final color front = color(210, 255, 210);
  private final color border = color(0, 255, 255);
  private final float radiusMultiplier = .9995; 
  // make sr smaller if symbols don't fit on card
  private final float angleDrag = .12;
  private final float displaySizeMultiplier = .975;



  public Card(int nSyms, int[] symIndices, float x, float y) {
    r = Tap_It.cardRadius; // making cardRadius final and static and initializing r here prevents a weird bug
    r *= width;
    borderWidth *= r;

    this.nSyms = nSyms;
    this.symIndices = symIndices;

    this.x = x;
    this.y = y;
    sr = 2.0 * r / sqrt(nSyms); // new symbol radius
    sx = new float[nSyms];
    sy = new float[nSyms];
    sa = new float[nSyms];
    // initialize positions for symbols
    int c = 0;
card:
    while (c < nSyms) {
      float rad = random(0, r - sr / 2.0); 
      // if the divisor of sr is greater than 1, some symbols will be outside card boundary
      float ang = random(0, 2.0 * PI);
      float newx = rad * cos(ang);
      float newy = rad * sin(ang);

      for (int i = 0; i < c; i++) {
        if ( dist(sx[i], sy[i], newx, newy) < 2.0 * sr) {
          sr *= radiusMultiplier; 
          continue card;
        }
      } 
      sx[c] = newx;
      sy[c] = newy;
      sa[c] = random(0, 2 * PI);
      c++;
    }
  }




  public void displayFront() {
    imageMode(CENTER);
    pushMatrix();
    translate(x, y);
    rotate(theta);

    fill(border);
    ellipse(0, 0, 2 * r, 2 * r);
    fill(front);
    noStroke();
    ellipse(0, 0, 2 * (r - borderWidth), 2 * (r - borderWidth));
    stroke(0);

    for (int c = 0; c < nSyms; c++) {
      pushMatrix();
      translate(sx[c], sy[c]);
      rotate(sa[c]);
      image(Tap_It.imageAtIndex(symIndices[c]), 0, 0, 
      displaySizeMultiplier * 2 * sr, displaySizeMultiplier * 2 * sr);
      popMatrix();
    }

    popMatrix();
  }

  public void displayBack() {
    // not implemented
  }




  public boolean hasSymbol(int symbolIndex) {
    for (int s : symIndices) 
      if (s == symbolIndex) 
        return true;
    return false;
  } 

  // return the index of symbol at the given x and y coordinates 
  // relative to the center of the card, or -1 if no symbol at these coordinates
  public int indexAtPosition(float x, float y) {
    for (int i = 0; i < nSyms; i++)
      if ( dist(x, y, sx[i], sy[i]) < sr ) return symIndices[i];
    return -1;
  }

  // change the location of the card on the canvas
  public void changePosition(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // reset the rotation angle to zero, this is called by deck on any card
  // added to the deck. this ensures that player enduced rotations of a
  // a card can't affect collision detection when the card goes back in the deck
  public void resetAngles() {
    theta = 0;
    omega = 0;
  }

  // update omega and the rotation angle theta of the card
  public void updateTheta() {
    omega *= (1 - angleDrag);
    theta += omega;
  }

  public void incrementOmega(float alpha) {
    omega += alpha;
  }

  // return the indices of the symbols on this card
  public int[] symbols() {
    return symIndices.clone(); // clone returns shallows copies EXCEPT for primitives
  }
}

