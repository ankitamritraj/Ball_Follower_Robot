
%--------------------------------------------------------MATLAB VIDEO PROCESSING------------------------------------------------------%
 

ser=serial('COM3','Baudrate',9600);  
fopen(ser);                                     % opens the COM3 channel port so that we can send the processed data to arduino;
                                                % The baud rate is the %rate at which information is transferred in a communication 
                                                % channel,"9600 baud" means that the serial port is capable of transferring a maximum
                                                % of 9600 bits per second
                                      
                                      
url = 'http://10.8.18.95:8080/shot.jpg';        % 'url' will recieve video from the shown link                  

while(1)
  
    im1=imread(url);                            % im1 will read video frame by frame
            
    im2= imsubtract(im1(:,:,1), rgb2gray(im1));         % converting RGB image to grayscale and subtracting all the 
                                                        % red coloured area. After converting all the red coloured
                                                        % area appear as white    
        
    [a b c]=size(im2);                         % a and b will store the resolution of the screen open
                                               % automatically after running the program
    
    y=a;                                       % in this case a=480px and b=640px i.e. 480x640                             
    x=b;

    im3 = medfilt2(im2, [3 3]);                % medfilt will filter out the unnecessary noise from the image                
      
    im3 = im2bw(im2,0.28);                     % here we are increasing the intensity of red colour so that it 
                                               % appears as white and any other color as black



    imshow(im3);  
    se = strel('disk',4);               
    im4 = bwareaopen(im3,8);                   % bwareaopen removes from a binary image all connected
                                               % components (objects)that have size fewer than 8 pixels.
                                               % bwareaopen will smoothen the edge of the object.
    
    im5 = imfill(im4,'holes');                 % imfill(BW,'holes') fills holes in the binary image im4. A  hole is  
                                               % a set of background pixels that cannot be reached % by filling in the 
                                               % background from the edge of the image. 
    
    [B,L] = bwboundaries(im5,'noholes');       % bwboundaries() traces the boundary of Red color object 

    stats = regionprops(L,'Area','Centroid');  % calculating the Area and the centroid

    circle_threshold = 0.70;                   % for circular object circle_threshold value is near 1 

    %initializing the variables area_cir,g,metric,g and centroid
    
    area_cir=1;                               
    g=1;
    centroid(1) = 1;
    centroid(2) = 1;
    metric = 0;

    imshow(im5);                                  % shows the final processed image
    pause(0.1);

    for g = 1:length(B)                           % loop over the boundaries
            
          
          boundary = B{g};                        % obtain (X,Y) boundary coordinates corresponding to label 'g'
          
          delta_sq = diff(boundary).^2;           % compute a simple estimate of the objects perimeter

          perimeter = sum(sqrt(sum(delta_sq,2)));
          area_cir = stats(g).Area;               % above will obtain the area calculation corresponding to label 'g'
          
          metric = 4*pi*area_cir/perimeter^2;     % compute the roundness metric
         
         if metric > circle_threshold             % Find the circle
              display(g);
              centroid = stats(g).Centroid;
         else
              [r,c] = find(L(:,:)==g);
              bw(r,c)=0;
         end
    end 							                            %end of for loop
    
    area_threshold= 0.1*a*b-5000; 

    display(area_threshold);                      %display area_threshold on command Window

    display(area_cir);                            %display area_cir on command Window
 
   if(metric >= circle_threshold && metric<=1.0)  % if the dectected object is nearly circular then only this segment will work
        
        display(metric);
        if (area_cir > area_threshold)            % if ball is to close to close i.e area of cirle is greater 
                                                  %than threshold area of cirle

            display('B');                         % display B on command Window

            fwrite(ser,'B');                      % write B to to COM3 port to send instruction to  Arduino and make the Robot stop
        else
            cenx=centroid(1);                     % position of X coordinate of centroid of object
            ceny=centroid(2);                     % position of Y coordinate of centroid of object

            display(cenx);              
            display(ceny);                        % displaying the coordinates on Command Window center region of the frame 
            X1=x/2+30;                 
            Y1=y/2+30;
            X2=x/2-70;
            Y2=y/2-70;
        if (cenx<X2 &&  cenx~=1 && ceny~=1)       % if the object is in the left side of center region frame
                                         
            %fprintf(ser,'D');
            display('L');           
            fwrite(ser,'L');                      % write L to COM3 port and turn left
        end  
            
            if (cenx>X1)                          % if the object is in the right side of center region frame

                display('R');
                fwrite(ser,'R');                  % write L to COM3 port and turn right
            end
            
            if (cenx>X2 && cenx<X1)               % if the object is in center region frame
                 % fprintf(ser,'E');

                 display('F');
                 fwrite(ser,'F');                 % write L to COM3 port and move forward
            end
 
        end    
   end    
end

