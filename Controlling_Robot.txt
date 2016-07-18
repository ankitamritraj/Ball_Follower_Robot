//--------------------------------------------------------------Run This On Arduino IDE-------------------------------------------------//

int inbyte=0;
int left1=5,left2=6;
int right1=9,right2=10;
void setup()
{
  Serial.begin(9600);
  pinMode(left1,OUTPUT);      //taking output through pin number 
  pinMode(left2,OUTPUT);
  pinMode(right1,OUTPUT);     
  pinMode(right2,OUTPUT);
}

void loop()
{
 
  if(Serial.available()>0)            // Check if we are recieving any input or not
  {
    inbyte=Serial.read();
    Serial.println(inbyte); 
   
    if(inbyte=='R')                   // If incoming input is R then move right
    {
      //Serial.println("right");
      analogWrite(left1,130);
      analogWrite(left2,0);
      analogWrite(right1,0);
      analogWrite(right2,0);
      delay(300);
     
     
    }
    else if(inbyte=='L')              // If incoming input is L then move left
    {
      //Serial.println("left");
      analogWrite(left1,0);
      analogWrite(left2,0);
      analogWrite(right1,130);
      analogWrite(right2,0);
      delay(300);
     
    }
    else if(inbyte=='F')              // If incoming input is F then move forward
    {
      //Serial.println("forward");
      analogWrite(left1,130);
      analogWrite(left2,0);
      analogWrite(right1,130);
      analogWrite(right2,0);
      delay(300);
     
    
      }
     else if(inbyte=='B')             // If incoming input is B then stop
     {
      //Serial.println("backward");
      analogWrite(left1,0);
      analogWrite(left2,0);
      analogWrite(right1,0);
      analogWrite(right2,0);
      delay(300);
     
     } 
   
  }
}