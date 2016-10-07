#!/usr/bin/env ruby -rubygems

newPath = File.dirname(__FILE__) + "/lib/"
$: << File.expand_path(newPath)

require 'opengl'
require 'glu'
require 'glut'
require 'socket'
require 'texture'
require 'matrix'

OpenGL.load_lib()
GLU.load_lib()
GLUT.load_lib("freeglut.dll", File.dirname(__FILE__))

include OpenGL
include GLU
include GLUT

require "FileUtils"

#logfile = File.new("C:/Users/Michael Sutton/logger.txt","w+")
#logfile.puts "in visualizer.rb "  
#logfile.close

require 'socket'

$radian = 0

def startServer
  #logfile0 = File.new("C:/Users/Michael Sutton/logger0.txt","w+")
  #logfile0.puts "in startServer"
  #logfile0.close
  BasicSocket.do_not_reverse_lookup = true
  #logfile0.puts "after BasicSocket"
  # Create socket and bind to address
  client = UDPSocket.new
  #logfile0.puts "after Client"
  client.bind(nil, 33333)
  #logfile0.puts "after bind"
  udpActive = true

  while udpActive do
    data, addr = client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
    #puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]  
    #logfile0.puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]  
    #sleep(0.01) #because sonic pi runs behind
    case data.to_s
    when "quit" 
      udpActive = false
    else
      commandparser(data.to_s)
    end
  end
  #logfile0.close
  client.close
end

def displayShape
  drawIndex = 0
  sleep $timesync.to_f
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  $drawArray.each do |drawElement|
    #puts "drawElement.action: " + drawElement.action.to_s
    if drawElement.killtimer > 0
      drawElement.killcntr += 1
      if drawElement.killcntr > drawElement.killtimer
        drawElement.action = "kill"
      end
    end  

    if drawElement.action.to_s != "kill"
      case drawElement.shape.to_s
      when "text"
        displayString(drawElement)
      when "point"
        displayPoint(drawElement)
      when "line"
        displayLine(drawElement)
      when "lineloop"
        displayLineLoop(drawElement)
      when "linestrip" 
        displayLineStrip(drawElement)     
      when "tri"
        displayTriangle(drawElement)
      when "tristrip"
        displayTriangleStrip(drawElement)  
      when "quad"
        displayQuad(drawElement)
      when "poly"
        displayPoly(drawElement)
      when "cube"
        displayCube(drawElement)
      when "teapot"
        displayTeapot(drawElement)
      when "sphere"
        displaySphere(drawElement)
      when "cone"
        displayCone(drawElement)
      when "torus"
        displayTorus(drawElement)
      when "dodecahedron"
        displayDodecahedron(drawElement)
      when "icosahedron"
        displayIcosahedron(drawElement)
      when "octahedron"
        displayOctahedron(drawElement)
      when "tetrahedron"
        displayTetrahedron(drawElement)           
      when "light"
        displayLight(drawElement)
      end      
    end
  end

  if $blend == "'A'"
    changeCanvas
  end
  if $blend == "'C'"
    changeCanvas
  end  
  if $blend == "'N'"
    changeCanvas
  end    
  glutSwapBuffers()
  glutPostRedisplay()

end

def rotateObj(rotateRate, rotateX, rotateY, rotateZ, rotcenterX, rotcenterY, rotcenterZ)
  glTranslatef(rotcenterX.to_f, rotcenterY.to_f, rotcenterZ.to_f)
  glRotatef(rotateRate.to_f, rotateX.to_f, rotateY.to_f, rotateZ.to_f)
  glTranslatef(rotcenterX.to_f * -1, rotcenterY.to_f * -1, rotcenterZ.to_f * -1)  
end

def translateObj(translateX, translateY, translateZ)
  glTranslatef(translateX.to_f, translateY.to_f, translateZ.to_f)
end

def scaleObj(scaleX, scaleY, scaleZ, rotcenterX, rotcenterY, rotcenterZ)
  glTranslatef(rotcenterX.to_f, rotcenterY.to_f, rotcenterZ.to_f)    
  glScalef(scaleX.to_f, scaleY.to_f, scaleZ.to_f)        
  glTranslatef(rotcenterX.to_f * -1, rotcenterY.to_f * -1, rotcenterZ.to_f * -1)     
end

def displayLight(lightIn)
  #puts "in displayLight"
  light_pos = [0.0, 0.5, -2.5, 1.0].pack('F4') unless light_pos
  light_diffuse  = [1.0, 1.0, 1.0, 1.0].pack('F4') unless light_diffuse
  light_specular = [1.0, 1.0, 1.0, 1.0].pack('F4') unless light_specular
  light_ambient  = [0.0, 0.0, 0.0, 1.0].pack('F4') unless light_ambient
  light_spotdirection = [0.0, -0.5, 2.5, 1.0].pack('F4') unless light_spotdirection
  light_spotcutoff = 12.0 unless light_spotcutoff
  light_spotexponent = 1
  glLightfv( GL_LIGHT0, GL_POSITION, light_pos )
  glLightfv( GL_LIGHT0, GL_DIFFUSE,  light_diffuse )
  glLightfv( GL_LIGHT0, GL_SPECULAR, light_specular )
  glLightfv( GL_LIGHT0, GL_AMBIENT,  light_ambient )
  glLightf( GL_LIGHT0, GL_SPOT_CUTOFF, light_spotcutoff )  
  glLightfv( GL_LIGHT0, GL_SPOT_DIRECTION, light_spotdirection )  
  glLightf( GL_LIGHT0, GL_SPOT_EXPONENT, light_spotexponent)
  
end

def displayColor(shapeIn)
  shape_diffuse = [shapeIn.difr.to_f, shapeIn.difg.to_f, shapeIn.difb.to_f, shapeIn.difa.to_f].pack('F4') unless shape_diffuse
  shape_specular = [shapeIn.spcr.to_f, shapeIn.spcg.to_f, shapeIn.spcb.to_f, shapeIn.spca.to_f].pack('F4') unless shape_specular
  shape_ambient = [shapeIn.ambr.to_f, shapeIn.ambg.to_f, shapeIn.ambb.to_f, shapeIn.amba.to_f].pack('F4') unless shape_ambient
  shape_emissive = [shapeIn.emmr.to_f, shapeIn.emmg.to_f, shapeIn.emmb.to_f, shapeIn.emma.to_f].pack('F4') unless shape_emissive
  shape_shininess = shapeIn.shininess.to_f unless shape_shininess
  glMaterialfv( GL_FRONT_AND_BACK, GL_DIFFUSE, shape_diffuse )
  glMaterialfv( GL_FRONT_AND_BACK, GL_SPECULAR, shape_specular )
  glMaterialfv( GL_FRONT_AND_BACK, GL_AMBIENT, shape_ambient )
  glMaterialfv( GL_FRONT_AND_BACK, GL_EMISSION, shape_emissive )  
  glMaterialf(  GL_FRONT_AND_BACK, GL_SHININESS, shape_shininess )
end

def displayString(textIn)
  glPushMatrix()
  if textIn.action != "kill"
    if textIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT)
    end
    if textIn.rotateRate != 0.0
      rotateObj(textIn.rotateRate, textIn.rotateX, textIn.rotateY, textIn.rotateZ, textIn.rotcenterX, textIn.rotcenterY, textIn.rotcenterZ)
    end  
    if textIn.translateX == 0.0 && textIn.translateY == 0.0 && textIn.translateZ == 0.0
      #do nothing
    else
      translateObj(textIn.translateX, textIn.translateY, textIn.translateZ)
    end
    glColor3f(textIn.scr.to_f, textIn.scg.to_f, textIn.scb.to_f)
    glRasterPos3f(textIn.textX.to_f, textIn.textY.to_f, textIn.textZ.to_f)

    case textIn.font.to_s
    when "GLUT_BITMAP_8_BY_13"    
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_8_BY_13, x)
      end
    when "GLUT_BITMAP_9_BY_15"
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_9_BY_15, x)
      end
    when "GLUT_BITMAP_TIMES_ROMAN_10"
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_10, x)
      end  
    when "GLUT_BITMAP_TIMES_ROMAN_24"
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, x)
      end  
    when "GLUT_BITMAP_HELVETICA_10"
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_10, x)
      end  
    when "GLUT_BITMAP_HELVETICA_12"
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12, x)
      end  
    when "GLUT_BITMAP_HELVETICA_18"
      textIn.text.to_s.each_byte do |x|
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, x)
      end
    end
  end
  glPopMatrix()
end

def displayPoint(pointIn) 
  glPushMatrix()
  if pointIn.action != "kill"  
    #set defaults
    if pointIn.p1x == 99.0
      pointIn.p1x = 0.1; pointIn.p1y = 0.1; pointIn.p1z = 0.0; pointIn.psize = 1.0;
      pointIn.b1r = 0.5; pointIn.b1g = 0.5; pointIn.b1b = 0.5; 
    end
    if pointIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT)
    end

    if pointIn.scalerX == 1.0 && pointIn.scalerY == 1.0 && pointIn.scalerZ == 1.0
      #do nothing
    else
      pointIn.scaleX = pointIn.scaleX + pointIn.scalerX; pointIn.scaleY = pointIn.scaleY + pointIn.scalerY; pointIn.scaleZ = pointIn.scaleZ + pointIn.scalerZ;
    end
    if pointIn.translaterX == 0.0 && pointIn.translaterY == 0.0 && pointIn.translaterZ == 0.0
      #do nothing
    else      
      pointIn.translateX = pointIn.translateX + pointIn.translaterX; pointIn.translateY = pointIn.translateY + pointIn.translaterY; pointIn.translateZ = pointIn.translateZ + pointIn.translaterZ;
    end

    if pointIn.translateX == 0.0 && pointIn.translateY == 0.0 && pointIn.translateZ == 0.0
      #do nothing
    else
      translateObj(pointIn.translateX, pointIn.translateY, pointIn.translateZ)
    end
    if pointIn.scaleX == 1.0 && pointIn.scaleY == 1.0 && pointIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(pointIn.scaleX pointIn.scaleY, pointIn.scaleZ)
    end
    glPointSize(pointIn.psize.to_f)
    glBegin(GL_POINTS)
      glColor3f(pointIn.scr.to_f, pointIn.scg.to_f, pointIn.scb.to_f)    
      glVertex3f(pointIn.p1x.to_f, pointIn.p1y.to_f, pointIn.p1z.to_f)
    glEnd()
  end
  glPopMatrix()
end

def displayLine(lineIn)
  glPushMatrix() 
  if lineIn.action != "kill"
    #set defaults
    if lineIn.p1x == 99.0
      lineIn.p1x = -0.5; lineIn.p1y = -0.5; lineIn.p1z = 0.0;
      lineIn.p2x = 0.5; lineIn.p2y = -0.5; lineIn.p2z = 0.0;
      lineIn.scr = 0.5; lineIn.scg = 0.5; lineIn.scb = 0.5;
      lineIn.b1r = 0.5; lineIn.b1g = 0.5; lineIn.b1b = 0.5; 
      lineIn.b2r = 0.5; lineIn.b2g = 0.5; lineIn.b2b = 0.5;    
    end
    if lineIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT)
    end

    if lineIn.rotaterRate != 0.0
      lineIn.rotateRate = lineIn.rotateRate + lineIn.rotaterRate
    end
    if lineIn.scalerX == 1.0 && lineIn.scalerY == 1.0 && lineIn.scalerZ == 1.0
      #do nothing
    else
      lineIn.scaleX = lineIn.scaleX + lineIn.scalerX; lineIn.scaleY = lineIn.scaleY + lineIn.scalerY; lineIn.scaleZ = lineIn.scaleZ + lineIn.scalerZ;
    end
    if lineIn.translaterX == 0.0 && lineIn.translaterY == 0.0 && lineIn.translaterZ == 0.0
      #do nothing
    else      
      lineIn.translateX = lineIn.translateX + lineIn.translaterX; lineIn.translateY = lineIn.translateY + lineIn.translaterY; lineIn.translateZ = lineIn.translateZ + lineIn.translaterZ;
    end

    if lineIn.rotateRate != 0.0
      rotateObj(lineIn.rotateRate, lineIn.rotateX, lineIn.rotateY, lineIn.rotateZ, lineIn.rotcenterX, lineIn.rotcenterY, lineIn.rotcenterZ)
    end
    if lineIn.translateX == 0.0 && lineIn.translateY == 0.0 && lineIn.translateZ == 0.0
      #do nothing
    else
      translateObj(lineIn.translateX, lineIn.translateY, lineIn.translateZ)
    end
    if lineIn.scaleX == 1.0 && lineIn.scaleY == 1.0 && lineIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(lineIn.scaleX, lineIn.scaleY, lineIn.scaleZ, lineIn.rotcenterX, lineIn.rotcenterY, lineIn.rotcenterZ)
    end  
    glBegin(GL_LINES)
      glColor3f(lineIn.scr.to_f, lineIn.scg.to_f, lineIn.scb.to_f)    
      glVertex3f(lineIn.p1x.to_f, lineIn.p1y.to_f, lineIn.p1z.to_f)
      glVertex3f(lineIn.p2x.to_f, lineIn.p2y.to_f, lineIn.p2z.to_f)
    glEnd()
  end
  glPopMatrix()
end

def createPointArray(arrayStr)
  xyzArrayInstance = []
  arrayStr2 = arrayStr.to_s[1...-2]
  xyzArrayInstance = arrayStr2.split('|')
  return xyzArrayInstance
end

def displayLineLoop(lineloopIn)
  glPushMatrix() 
  if lineloopIn.action != "kill"
    #set defaults
    if lineloopIn.p1x == 99.0
      lineloopIn.p1x = -0.5; lineloopIn.p1y = -0.5; lineloopIn.p1z = 0.0;
      lineloopIn.p2x = 0.5; lineloopIn.p2y = -0.5; lineloopIn.p2z = 0.0;
    end
    if lineloopIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT)
    end

    if lineloopIn.rotaterRate != 0.0
      lineloopIn.rotateRate = lineloopIn.rotateRate + lineloopIn.rotaterRate
    end
    if lineloopIn.scalerX == 1.0 && lineloopIn.scalerY == 1.0 && lineloopIn.scalerZ == 1.0
      #do nothing
    else
      lineloopIn.scaleX = lineloopIn.scaleX + lineloopIn.scalerX; lineloopIn.scaleY = lineloopIn.scaleY + lineloopIn.scalerY; lineloopIn.scaleZ = lineloopIn.scaleZ + lineloopIn.scalerZ;
    end
    if lineloopIn.translaterX == 0.0 && lineloopIn.translaterY == 0.0 && lineloopIn.translaterZ == 0.0
      #do nothing
    else      
      lineloopIn.translateX = lineloopIn.translateX + lineloopIn.translaterX; lineloopIn.translateY = lineloopIn.translateY + lineloopIn.translaterY; lineloopIn.translateZ = lineloopIn.translateZ + lineloopIn.translaterZ;
    end

    if lineloopIn.rotateRate != 0.0
      rotateObj(lineloopIn.rotateRate, lineloopIn.rotateX, lineloopIn.rotateY, lineloopIn.rotateZ, lineloopIn.rotcenterX, lineloopIn.rotcenterY, lineloopIn.rotcenterZ)
    end
    if lineloopIn.translateX == 0.0 && lineloopIn.translateY == 0.0 && lineloopIn.translateZ == 0.0
      #do nothing
    else
      translateObj(lineloopIn.translateX, lineloopIn.translateY, lineloopIn.translateZ)
    end
    if lineloopIn.scaleX == 1.0 && lineloopIn.scaleY == 1.0 && lineloopIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(lineloopIn.scaleX, lineloopIn.scaleY, lineloopIn.scaleZ, lineloopIn.rotcenterX, lineloopIn.rotcenterY, lineloopIn.rotcenterZ)
    end
    xyzArrayInstance = []
    if lineloopIn.xyzArray.length.to_i > 0
      arrayIn = lineloopIn.xyzArray.to_s
      xyzArrayInstance = createPointArray(arrayIn)
    end
    glBegin(GL_LINE_LOOP)
      glColor3f(lineloopIn.scr.to_f, lineloopIn.scg.to_f, lineloopIn.scb.to_f)
      if lineloopIn.xyzArray.length.to_i > 0
        numofpoints = xyzArrayInstance.length
      else  
        if lineloopIn.p1x != 99.0 
          xyzArrayInstance.push lineloopIn.p1x.to_f; xyzArrayInstance.push lineloopIn.p1y.to_f; xyzArrayInstance.push lineloopIn.p1z.to_f;
          numofpoints = 4
        end
        if lineloopIn.p2x != 99.0
          xyzArrayInstance.push lineloopIn.p2x.to_f; xyzArrayInstance.push lineloopIn.p2y.to_f; xyzArrayInstance.push lineloopIn.p2z.to_f;
          numofpoints = 6
        end
        if lineloopIn.p3x != 99.0   
          xyzArrayInstance.push lineloopIn.p4x.to_f; xyzArrayInstance.push lineloopIn.p3y.to_f; xyzArrayInstance.push lineloopIn.p3z.to_f;
          numofpoints = 9
        end
        if lineloopIn.p4x != 99.0
          xyzArrayInstance.push lineloopIn.p4x.to_f; xyzArrayInstance.push lineloopIn.p4y.to_f; xyzArrayInstance.push lineloopIn.p4z.to_f;
          numofpoints = 12
        end
        if lineloopIn.p5x != 99.0
          xyzArrayInstance.push lineloopIn.p5x.to_f; xyzArrayInstance.push lineloopIn.p5y.to_f; xyzArrayInstance.push lineloopIn.p5z.to_f;
          numofpoints = 15
        end
        if lineloopIn.p6x != 99.0
          xyzArrayInstance.push lineloopIn.p6x.to_f; xyzArrayInstance.push lineloopIn.p6y.to_f; xyzArrayInstance.push lineloopIn.p6z.to_f;
          numofpoints = 18
        end
        if lineloopIn.p7x != 99.0
          xyzArrayInstance.push lineloopIn.p7x.to_f; xyzArrayInstance.push lineloopIn.p7y.to_f; xyzArrayInstance.push lineloopIn.p7z.to_f;
          numofpoints = 21
        end
        if lineloopIn.p8x != 99.0
          xyzArrayInstance.push lineloopIn.p8x.to_f; xyzArrayInstance.push lineloopIn.p8y.to_f; xyzArrayInstance.push lineloopIn.p8z.to_f;
          numofpoints = 24
        end
        if lineloopIn.p9x != 99.0
          xyzArrayInstance.push lineloopIn.p9x.to_f; xyzArrayInstance.push lineloopIn.p9y.to_f; xyzArrayInstance.push lineloopIn.p9z.to_f;
          numofpoints = 27
        end
        if lineloopIn.p10x != 99.0
          xyzArrayInstance.push lineloopIn.p10x.to_f; xyzArrayInstance.push lineloopIn.p10y.to_f; xyzArrayInstance.push lineloopIn.p10z.to_f;
          numofpoints = 30
        end
        if lineloopIn.p11x != 99.0
          xyzArrayInstance.push lineloopIn.p11x.to_f; xyzArrayInstance.push lineloopIn.p11y.to_f; xyzArrayInstance.push lineloopIn.p11z.to_f;
          numofpoints = 33
        end
        if lineloopIn.p12x != 99.0
          xyzArrayInstance.push lineloopIn.p12x.to_f; xyzArrayInstance.push lineloopIn.p12y.to_f; xyzArrayInstance.push lineloopIn.p12z.to_f;
          numofpoints = 36
        end
        if lineloopIn.p13x != 99.0
          xyzArrayInstance.push lineloopIn.p13x.to_f; xyzArrayInstance.push lineloopIn.p13y.to_f; xyzArrayInstance.push lineloopIn.p13z.to_f;
          numofpoints = 39
        end
        if lineloopIn.p14x != 99.0
          xyzArrayInstance.push lineloopIn.p14x.to_f; xyzArrayInstance.push lineloopIn.p14y.to_f; xyzArrayInstance.push lineloopIn.p14z.to_f;
          numofpoints = 42
        end
        if lineloopIn.p15x != 99.0
          xyzArrayInstance.push lineloopIn.p15x.to_f; xyzArrayInstance.push lineloopIn.p15y.to_f; xyzArrayInstance.push lineloopIn.p15z.to_f;
          numofpoints = 45
        end
        if lineloopIn.p16x != 99.0
          xyzArrayInstance.push lineloopIn.p16x.to_f; xyzArrayInstance.push lineloopIn.p16y.to_f; xyzArrayInstance.push lineloopIn.p16z.to_f;
          numofpoints = 48
        end
      end
      looppoints = numofpoints.to_i-1
      for i in (0..looppoints.to_i).step(3)                          
        glVertex3f(xyzArrayInstance[i].to_f, xyzArrayInstance[i+1].to_f, xyzArrayInstance[i+2].to_f)
      end           
    glEnd()
  end
  glPopMatrix()
end

def displayLineStrip(linestripIn) 
  #set defaults

  if linestripIn.p1x == 99.0
    linestripIn.p1x = -0.5; linestripIn.p1y = -0.5; linestripIn.p1z = 0.0;
    linestripIn.p2x = 0.5; linestripIn.p2y = -0.5; linestripIn.p2z = 0.0;
    linestripIn.scr = 0.5; linestripIn.scg = 0.5; linestripIn.scb = 0.5; linestripIn.sca = 1.0;    
  end
  if linestripIn.clear == "Y"
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  end

    if linestripIn.rotaterRate != 0.0
      linestripIn.rotateRate = linestripIn.rotateRate + linestripIn.rotaterRate
    end
    if linestripIn.scalerX == 1.0 && linestripIn.scalerY == 1.0 && linestripIn.scalerZ == 1.0
      #do nothing
    else
      linestripIn.scaleX = linestripIn.scaleX + linestripIn.scalerX; linestripIn.scaleY = linestripIn.scaleY + linestripIn.scalerY; linestripIn.scaleZ = linestripIn.scaleZ + linestripIn.scalerZ;
    end
    if linestripIn.translaterX == 0.0 && linestripIn.translaterY == 0.0 && linestripIn.translaterZ == 0.0
      #do nothing
    else      
      linestripIn.translateX = linestripIn.translateX + linestripIn.translaterX; linestripIn.translateY = linestripIn.translateY + linestripIn.translaterY; linestripIn.translateZ = linestripIn.translateZ + linestripIn.translaterZ;
    end

  if linestripIn.rotateRate != 0.0
    rotateObj(linestripIn.rotateRate, linestripIn.rotateX, linestripIn.rotateY, linestripIn.rotateZ, linestripIn.rotcenterX, linestripIn.rotcenterY, linestripIn.rotcenterZ)
  end
  if linestripIn.translateX == 0.0 && linestripIn.translateY == 0.0 && linestripIn.translateZ == 0.0
    #do nothing
  else
    translateObj(linestripIn.translateX, linestripIn.translateY, linestripIn.translateZ)
  end
  if linestripIn.scaleX == 1.0 && linestripIn.scaleY == 1.0 && linestripIn.scaleZ == 1.0
    #do nothing
  else       
    scaleObj(linestripIn.scaleX, linestripIn.scaleY, linestripIn.scaleZ, linestripIn.rotcenterX, linestripIn.rotcenterY, linestripIn.rotcenterZ)
  end
  xyzArrayInstance = []
  if linestripIn.xyzArray.length.to_i > 0
    arrayIn = linestripIn.xyzArray.to_s
    xyzArrayInstance = createPointArray(arrayIn)
  end
  glBegin(GL_LINE_STRIP)
    if linestripIn.cType == "solid"
      glColor3f(linestripIn.scr.to_f, linestripIn.scg.to_f, linestripIn.scb.to_f)
    end
    if linestripIn.cType.to_s == "shader"
      displayColor(linestripIn)
    end
    if linestripIn.xyzArray.length.to_i > 0
      numofpoints = xyzArrayInstance.length
    else  
      if linestripIn.p1x != 99.0 
        xyzArrayInstance.push linestripIn.p1x.to_f; xyzArrayInstance.push linestripIn.p1y.to_f; xyzArrayInstance.push linestripIn.p1z.to_f;
        numofpoints = 4
      end
      if linestripIn.p2x != 99.0
        xyzArrayInstance.push linestripIn.p2x.to_f; xyzArrayInstance.push linestripIn.p2y.to_f; xyzArrayInstance.push linestripIn.p2z.to_f;
        numofpoints = 6
      end
      if linestripIn.p3x != 99.0   
        xyzArrayInstance.push linestripIn.p4x.to_f; xyzArrayInstance.push linestripIn.p3y.to_f; xyzArrayInstance.push linestripIn.p3z.to_f;
        numofpoints = 9
      end
      if linestripIn.p4x != 99.0
        xyzArrayInstance.push linestripIn.p4x.to_f; xyzArrayInstance.push linestripIn.p4y.to_f; xyzArrayInstance.push linestripIn.p4z.to_f;
        numofpoints = 12
      end
      if linestripIn.p5x != 99.0
        xyzArrayInstance.push linestripIn.p5x.to_f; xyzArrayInstance.push linestripIn.p5y.to_f; xyzArrayInstance.push linestripIn.p5z.to_f;
        numofpoints = 15
      end
      if linestripIn.p6x != 99.0
        xyzArrayInstance.push linestripIn.p6x.to_f; xyzArrayInstance.push linestripIn.p6y.to_f; xyzArrayInstance.push linestripIn.p6z.to_f;
        numofpoints = 18
      end
      if linestripIn.p7x != 99.0
        xyzArrayInstance.push linestripIn.p7x.to_f; xyzArrayInstance.push linestripIn.p7y.to_f; xyzArrayInstance.push linestripIn.p7z.to_f;
        numofpoints = 21
      end
      if linestripIn.p8x != 99.0
        xyzArrayInstance.push linestripIn.p8x.to_f; xyzArrayInstance.push linestripIn.p8y.to_f; xyzArrayInstance.push linestripIn.p8z.to_f;
        numofpoints = 24
      end
      if linestripIn.p9x != 99.0
        xyzArrayInstance.push linestripIn.p9x.to_f; xyzArrayInstance.push linestripIn.p9y.to_f; xyzArrayInstance.push linestripIn.p9z.to_f;
        numofpoints = 27
      end
      if linestripIn.p10x != 99.0
        xyzArrayInstance.push linestripIn.p10x.to_f; xyzArrayInstance.push linestripIn.p10y.to_f; xyzArrayInstance.push linestripIn.p10z.to_f;
        numofpoints = 30
      end
      if linestripIn.p11x != 99.0
        xyzArrayInstance.push linestripIn.p11x.to_f; xyzArrayInstance.push linestripIn.p11y.to_f; xyzArrayInstance.push linestripIn.p11z.to_f;
        numofpoints = 33
      end
      if linestripIn.p12x != 99.0
        xyzArrayInstance.push linestripIn.p12x.to_f; xyzArrayInstance.push linestripIn.p12y.to_f; xyzArrayInstance.push linestripIn.p12z.to_f;
        numofpoints = 36
      end
      if linestripIn.p13x != 99.0
        xyzArrayInstance.push linestripIn.p13x.to_f; xyzArrayInstance.push linestripIn.p13y.to_f; xyzArrayInstance.push linestripIn.p13z.to_f;
        numofpoints = 39
      end
      if linestripIn.p14x != 99.0
        xyzArrayInstance.push linestripIn.p14x.to_f; xyzArrayInstance.push linestripIn.p14y.to_f; xyzArrayInstance.push linestripIn.p14z.to_f;
        numofpoints = 42
      end
      if linestripIn.p15x != 99.0
        xyzArrayInstance.push linestripIn.p15x.to_f; xyzArrayInstance.push linestripIn.p15y.to_f; xyzArrayInstance.push linestripIn.p15z.to_f;
        numofpoints = 45
      end
      if linestripIn.p16x != 99.0
        xyzArrayInstance.push linestripIn.p16x.to_f; xyzArrayInstance.push linestripIn.p16y.to_f; xyzArrayInstance.push linestripIn.p16z.to_f;
        numofpoints = 48
      end
    end
    looppoints = numofpoints.to_i-1
    for i in (0..looppoints.to_i).step(3)                          
      glVertex3f(xyzArrayInstance[i].to_f, xyzArrayInstance[i+1].to_f, xyzArrayInstance[i+2].to_f)
    end           
  glEnd()
end

def displayTriangle(triIn)
  #puts "tri: " + triIn.sid.to_s
  glPushMatrix()
  if triIn.action != "kill"
    if triIn.p1x == 99.0
      triIn.p1x = -0.5; triIn.p1y = -0.5; triIn.p1z = 0.0;
      triIn.p2x = 0.5; triIn.p2y = -0.5; triIn.p2z = 0.0;
      triIn.p3x = 0.0; triIn.p3y = 0.5; triIn.p3z = 0.0;
      triIn.b1r = 0.5; triIn.b1g = 0.5; triIn.b1b = 0.5; 
      triIn.b2r = 0.5; triIn.b2g = 0.5; triIn.b2b = 0.5;
      triIn.b3r = 0.5; triIn.b3g = 0.5; triIn.b3b = 0.5;
    end
    if triIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    if triIn.rotaterRate != 0.0
      triIn.rotateRate = triIn.rotateRate + triIn.rotaterRate
    end
    if triIn.scalerX == 1.0 && triIn.scalerY == 1.0 && triIn.scalerZ == 1.0
      #do nothing
    else
      triIn.scaleX = triIn.scaleX + triIn.scalerX; triIn.scaleY = triIn.scaleY + triIn.scalerY; triIn.scaleZ = triIn.scaleZ + triIn.scalerZ;
    end
    if triIn.translaterX == 0.0 && triIn.translaterY == 0.0 && triIn.translaterZ == 0.0
      #do nothing
    else      
      triIn.translateX = triIn.translateX + triIn.translaterX; triIn.translateY = triIn.translateY + triIn.translaterY; triIn.translateZ = triIn.translateZ + triIn.translaterZ;
    end

    if triIn.rotateRate == 0.0
      #rotateObj(0.0, 0.0, 0.0, 0.0)
    else
      rotateObj(triIn.rotateRate, triIn.rotateX, triIn.rotateY, triIn.rotateZ, triIn.rotcenterX, triIn.rotcenterY, triIn.rotcenterZ)
    end
    if triIn.translateX == 0.0 && triIn.translateY == 0.0 && triIn.translateZ == 0.0
      #translateObj(0.0, 0.0, 0.0)
    else
      translateObj(triIn.translateX, triIn.translateY, triIn.translateZ)
    end
    if triIn.scaleX == 1.0 && triIn.scaleY == 1.0 && triIn.scaleZ == 1.0
      #scaleObj(1.0, 1.0, 1.0)
    else       
      scaleObj(triIn.scaleX, triIn.scaleY, triIn.scaleZ, triIn.rotcenterX, triIn.rotcenterY, triIn.rotcenterZ)
    end
    glBegin(GL_TRIANGLES)
      if triIn.cType.to_s == "solid"
        glColor3f(triIn.scr.to_f, triIn.scg.to_f, triIn.scb.to_f)
      end
      if triIn.cType.to_s == "shader"
        displayColor(triIn)
      end      
      if triIn.cType.to_s == "alpha"
        glColor4f(triIn.scr.to_f, triIn.scg.to_f, triIn.scb.to_f, triIn.sca.to_f)
      end
      if triIn.cType == "blend"
        glColor3f(triIn.b1r.to_f, triIn.b1g.to_f, triIn.b1b.to_f)
      end
      glVertex3f(triIn.p1x.to_f, triIn.p1y.to_f, triIn.p1z.to_f)
      if triIn.cType == "blend"
        glColor3f(triIn.b2r.to_f, triIn.b2g.to_f, triIn.b2b.to_f)   
      end
      glVertex3f(triIn.p2x.to_f, triIn.p2y.to_f, triIn.p2z.to_f)
      if triIn.cType == "blend"
        glColor3f(triIn.b3r.to_f, triIn.b3g.to_f, triIn.b3b.to_f)   
      end
      glVertex3f(triIn.p3x.to_f, triIn.p3y.to_f, triIn.p3z.to_f)     
    glEnd()
  end
  glPopMatrix()
end

def displayTriangleStrip(tristripIn)
  if tristripIn.action != "kill"
    if tristripIn.p1x == 99.0
      tristripIn.p1x = 0.0; tristripIn.p1y = 0.75; tristripIn.p1z = 0.0;
      tristripIn.p2x = -0.5; tristripIn.p2y = 0.25; tristripIn.p2z = 0.0;
      tristripIn.p3x = 0.5; tristripIn.p3y = 0.25; tristripIn.p3z = 0.0;
      tristripIn.p4x = -0.5; tristripIn.p4y = -0.5; tristripIn.p4z = 0.0;
      tristripIn.p5x = 0.5; tristripIn.p5y = -0.5; tristripIn.p5z = 0.0;   
      tristripIn.b1r = 0.5; tristripIn.b1g = 0.5; tristripIn.b1b = 0.5; 
      tristripIn.b2r = 0.5; tristripIn.b2g = 0.5; tristripIn.b2b = 0.5;
      tristripIn.b3r = 0.5; tristripIn.b3g = 0.5; tristripIn.b3b = 0.5;
      tristripIn.b4r = 0.5; tristripIn.b4g = 0.5; tristripIn.b4b = 0.5;
      tristripIn.b5r = 0.5; tristripIn.b5g = 0.5; tristripIn.b5b = 0.5;  
    end
    if tristripIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    if tristripIn.rotaterRate != 0.0
      tristripIn.rotateRate = tristripIn.rotateRate + tristripIn.rotaterRate
    end
    if tristripIn.scalerX == 1.0 && tristripIn.scalerY == 1.0 && tristripIn.scalerZ == 1.0
      #do nothing
    else
      tristripIn.scaleX = tristripIn.scaleX + tristripIn.scalerX; tristripIn.scaleY = tristripIn.scaleY + tristripIn.scalerY; tristripIn.scaleZ = tristripIn.scaleZ + tristripIn.scalerZ;
    end
    if tristripIn.translaterX == 0.0 && tristripIn.translaterY == 0.0 && tristripIn.translaterZ == 0.0
      #do nothing
    else      
      tristripIn.translateX = tristripIn.translateX + tristripIn.translaterX; tristripIn.translateY = tristripIn.translateY + tristripIn.translaterY; tristripIn.translateZ = tristripIn.translateZ + tristripIn.translaterZ;
    end

    if tristripIn.rotateRate != 0.0
      rotateObj(tristripIn.rotateRate, tristripIn.rotateX, tristripIn.rotateY, tristripIn.rotateZ, tristripIn.rotcenterX, tristripIn.rotcenterY, tristripIn.rotcenterZ)
    end
    if tristripIn.translateX == 0.0 && tristripIn.translateY == 0.0 && tristripIn.translateZ == 0.0
      #do nothing
    else
      translateObj(tristripIn.translateX, tristripIn.translateY, tristripIn.translateZ)
    end
    if tristripIn.scaleX == 1.0 && tristripIn.scaleY == 1.0 && tristripIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(tristripIn.scaleX, tristripIn.scaleY, tristripIn.scaleZ, tristripIn.rotcenterX, tristripIn.rotcenterY, tristripIn.rotcenterZ)
    end
    xyzArrayInstance = []
    if tristripIn.xyzArray.length.to_i > 0
      arrayIn = tristripIn.xyzArray.to_s
      xyzArrayInstance = createPointArray(arrayIn)
    end
    glBegin(GL_TRIANGLE_STRIP)
      if tristripIn.cType == "solid"
        glColor3f(tristripIn.scr.to_f, tristripIn.scg.to_f, tristripIn.scb.to_f)
      end
      if tristripIn.cType.to_s == "shader"
        displayColor(tristripIn)
      end
      if tristripIn.xyzArray.length.to_i > 0
        numofpoints = xyzArrayInstance.length
      else  
        if tristripIn.p1x != 99.0 
          xyzArrayInstance.push tristripIn.p1x.to_f; xyzArrayInstance.push tristripIn.p1y.to_f; xyzArrayInstance.push tristripIn.p1z.to_f;
          numofpoints = 4
        end
        if tristripIn.p2x != 99.0
          xyzArrayInstance.push tristripIn.p2x.to_f; xyzArrayInstance.push tristripIn.p2y.to_f; xyzArrayInstance.push tristripIn.p2z.to_f;
          numofpoints = 6
        end
        if tristripIn.p3x != 99.0   
          xyzArrayInstance.push tristripIn.p4x.to_f; xyzArrayInstance.push tristripIn.p3y.to_f; xyzArrayInstance.push tristripIn.p3z.to_f;
          numofpoints = 9
        end
        if tristripIn.p4x != 99.0
          xyzArrayInstance.push tristripIn.p4x.to_f; xyzArrayInstance.push tristripIn.p4y.to_f; xyzArrayInstance.push tristripIn.p4z.to_f;
          numofpoints = 12
        end
        if tristripIn.p5x != 99.0
          xyzArrayInstance.push tristripIn.p5x.to_f; xyzArrayInstance.push tristripIn.p5y.to_f; xyzArrayInstance.push tristripIn.p5z.to_f;
          numofpoints = 15
        end
        if tristripIn.p6x != 99.0
          xyzArrayInstance.push tristripIn.p6x.to_f; xyzArrayInstance.push tristripIn.p6y.to_f; xyzArrayInstance.push tristripIn.p6z.to_f;
          numofpoints = 18
        end
        if tristripIn.p7x != 99.0
          xyzArrayInstance.push tristripIn.p7x.to_f; xyzArrayInstance.push tristripIn.p7y.to_f; xyzArrayInstance.push tristripIn.p7z.to_f;
          numofpoints = 21
        end
        if tristripIn.p8x != 99.0
          xyzArrayInstance.push tristripIn.p8x.to_f; xyzArrayInstance.push tristripIn.p8y.to_f; xyzArrayInstance.push tristripIn.p8z.to_f;
          numofpoints = 24
        end
        if tristripIn.p9x != 99.0
          xyzArrayInstance.push tristripIn.p9x.to_f; xyzArrayInstance.push tristripIn.p9y.to_f; xyzArrayInstance.push tristripIn.p9z.to_f;
          numofpoints = 27
        end
        if tristripIn.p10x != 99.0
          xyzArrayInstance.push tristripIn.p10x.to_f; xyzArrayInstance.push tristripIn.p10y.to_f; xyzArrayInstance.push tristripIn.p10z.to_f;
          numofpoints = 30
        end
        if tristripIn.p11x != 99.0
          xyzArrayInstance.push tristripIn.p11x.to_f; xyzArrayInstance.push tristripIn.p11y.to_f; xyzArrayInstance.push tristripIn.p11z.to_f;
          numofpoints = 33
        end
        if tristripIn.p12x != 99.0
          xyzArrayInstance.push tristripIn.p12x.to_f; xyzArrayInstance.push tristripIn.p12y.to_f; xyzArrayInstance.push tristripIn.p12z.to_f;
          numofpoints = 36
        end
        if tristripIn.p13x != 99.0
          xyzArrayInstance.push tristripIn.p13x.to_f; xyzArrayInstance.push tristripIn.p13y.to_f; xyzArrayInstance.push tristripIn.p13z.to_f;
          numofpoints = 39
        end
        if tristripIn.p14x != 99.0
          xyzArrayInstance.push tristripIn.p14x.to_f; xyzArrayInstance.push tristripIn.p14y.to_f; xyzArrayInstance.push tristripIn.p14z.to_f;
          numofpoints = 42
        end
        if tristripIn.p15x != 99.0
          xyzArrayInstance.push tristripIn.p15x.to_f; xyzArrayInstance.push tristripIn.p15y.to_f; xyzArrayInstance.push tristripIn.p15z.to_f;
          numofpoints = 45
        end
        if tristripIn.p16x != 99.0
          xyzArrayInstance.push tristripIn.p16x.to_f; xyzArrayInstance.push tristripIn.p16y.to_f; xyzArrayInstance.push tristripIn.p16z.to_f;
          numofpoints = 48
        end
      end
      looppoints = numofpoints.to_i-1
      for i in (0..looppoints.to_i).step(3)                          
        glVertex3f(xyzArrayInstance[i].to_f, xyzArrayInstance[i+1].to_f, xyzArrayInstance[i+2].to_f)
      end           
    glEnd()
  end
end

def displayQuad(quadIn)
  glPushMatrix()
  if quadIn.action != "kill"
    textureIn = "none"
    if quadIn.p1x == 99.0
      quadIn.p1x = -0.5; quadIn.p1y = -0.5; quadIn.p1z = 0.0;
      quadIn.p2x = 0.5; quadIn.p2y = -0.5; quadIn.p2z = 0.0;
      quadIn.p3x = 0.5; quadIn.p3y = 0.5; quadIn.p3z = 0.0;
      quadIn.p4x = -0.5; quadIn.p4y = 0.5; quadIn.p4z = 0.0;
      quadIn.scr = 0.5; quadIn.scg = 0.5; quadIn.scb = 0.5;
      quadIn.b1r = 0.5; quadIn.b1g = 0.5; quadIn.b1b = 0.5; 
      quadIn.b2r = 0.5; quadIn.b2g = 0.5; quadIn.b2b = 0.5;
      quadIn.b3r = 0.5; quadIn.b3g = 0.5; quadIn.b3b = 0.5;
      quadIn.b4r = 0.5; quadIn.b4g = 0.5; quadIn.b4b = 0.5;  
    end
    if quadIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    if quadIn.rotaterRate != 0.0
      quadIn.rotateRate = quadIn.rotateRate + quadIn.rotaterRate
    end
    if quadIn.scalerX == 1.0 && quadIn.scalerY == 1.0 && quadIn.scalerZ == 1.0
      #do nothing
    else
      quadIn.scaleX = quadIn.scaleX + quadIn.scalerX; quadIn.scaleY = quadIn.scaleY + quadIn.scalerY; quadIn.scaleZ = quadIn.scaleZ + quadIn.scalerZ;
    end
    if quadIn.translaterX == 0.0 && quadIn.translaterY == 0.0 && quadIn.translaterZ == 0.0
      #do nothing
    else      
      quadIn.translateX = quadIn.translateX + quadIn.translaterX; quadIn.translateY = quadIn.translateY + quadIn.translaterY; quadIn.translateZ = quadIn.translateZ + quadIn.translaterZ;
    end

    if quadIn.rotateRate == 0.0
      #do nothing
      else
      rotateObj(quadIn.rotateRate, quadIn.rotateX, quadIn.rotateY, quadIn.rotateZ, quadIn.rotcenterX, quadIn.rotcenterY, quadIn.rotcenterZ)
    end
    if quadIn.translateX == 0.0 && quadIn.translateY == 0.0 && quadIn.translateZ == 0.0
      #do nothing
    else
      translateObj(quadIn.translateX, quadIn.translateY, quadIn.translateZ)
    end
    if quadIn.scaleX == 1.0 && quadIn.scaleY == 1.0 && quadIn.scaleZ == 1.0
      #do nothing
    else     
      scaleObj(quadIn.scaleX, quadIn.scaleY, quadIn.scaleZ, quadIn.rotcenterX, quadIn.rotcenterY, quadIn.rotcenterZ)
    end

    if quadIn.cType == "texture"
      if textureIn == "none"
        glEnable(GL_TEXTURE_2D)
        textureIn = Texture.new(quadIn.texture)    
        textureIn.generate
        textureIn.bind
        glColor3f(1.0, 1.0, 1.0)
      end
    else
      glDisable(GL_TEXTURE_2D)
    end
    glBegin(GL_QUADS)
      if quadIn.cType.to_s == "solid"
        glColor3f(quadIn.scr.to_f, quadIn.scg.to_f, quadIn.scb.to_f)
      end
      if quadIn.cType.to_s == "shader"
        displayColor(quadIn)
      end
      if quadIn.cType.to_s == "alpha"     
        glColor4f(quadIn.scr.to_f, quadIn.scg.to_f, quadIn.scb.to_f, quadIn.sca.to_f)
      end    
      if quadIn.cType == "blend"
        glColor3f(quadIn.b1r.to_f, quadIn.b1g.to_f, quadIn.b1b.to_f)
      end
      if quadIn.cType.to_s == "texture"
        glTexCoord2f(0, 1)                 
      end          
      glVertex3f(quadIn.p1x.to_f, quadIn.p1y.to_f, quadIn.p1z.to_f)
      if quadIn.cType == "blend"
        glColor3f(quadIn.b2r.to_f, quadIn.b2g.to_f, quadIn.b2b.to_f)   
      end
      if quadIn.cType.to_s == "texture"
        glTexCoord2f(1, 1)                         
      end    
      glVertex3f(quadIn.p2x.to_f, quadIn.p2y.to_f, quadIn.p2z.to_f)
      if quadIn.cType.to_s == "blend"
        glColor3f(quadIn.b3r.to_f, quadIn.b3g.to_f, quadIn.b3b.to_f)   
      end
      if quadIn.cType == "texture"
        glTexCoord2f(1, 0)                      
      end    
      glVertex3f(quadIn.p3x.to_f, quadIn.p3y.to_f, quadIn.p3z.to_f)
      if quadIn.cType == "blend"
        glColor3f(quadIn.b4r.to_f, quadIn.b4g.to_f, quadIn.b4b.to_f)   
      end
      if quadIn.cType.to_s == "texture"
        glTexCoord2f(0, 0)       
      end    
      glVertex3f(quadIn.p4x.to_f, quadIn.p4y.to_f, quadIn.p4z.to_f)
    glEnd()
  end
  glPopMatrix()
end

def regPoly (argsIn)

  numofpoints = argsIn.numofpoints
  centerX = argsIn.centerX
  centerY = argsIn.centerY
  centerZ = argsIn.centerZ
  radius = argsIn.radius

  xyzCalcArray = []
  angle = 2 * Math::PI / numofpoints.to_f
  for i in 0..numofpoints.to_i
    x = centerX.to_f + radius.to_f * (Math.cos(2 * Math::PI * i.to_f / numofpoints.to_f))
    xyzCalcArray.push x.round(4).to_f
    y = centerY.to_f + radius.to_f * (Math.sin(2 * Math::PI * i.to_f / numofpoints.to_f))   
    xyzCalcArray.push y.round(4).to_f    
    xyzCalcArray.push centerZ
  end
  return xyzCalcArray 
end

def displayPoly(polyIn)
  glPushMatrix()
  if polyIn.action != "kill"
    #set defaults
    if polyIn.p1x == 99.0
      polyIn.p1x = 0.0; polyIn.p1y = 0.75; polyIn.p1z = 0.0;
      polyIn.p2x = -0.5; polyIn.p2y = 0.25; polyIn.p2z = 0.0;
      polyIn.p3x = 0.5; polyIn.p3y = 0.25; polyIn.p3z = 0.0;
      polyIn.p4x = -0.5; polyIn.p4y = -0.5; polyIn.p4z = 0.0;
      polyIn.p5x = 0.5; polyIn.p5y = -0.5; polyIn.p5z = 0.0;   
      polyIn.b1r = 0.5; polyIn.b1g = 0.5; polyIn.b1b = 0.5; 
      polyIn.b2r = 0.5; polyIn.b2g = 0.5; polyIn.b2b = 0.5;
      polyIn.b3r = 0.5; polyIn.b3g = 0.5; polyIn.b3b = 0.5;
      polyIn.b4r = 0.5; polyIn.b4g = 0.5; polyIn.b4b = 0.5;
      polyIn.b5r = 0.5; polyIn.b5g = 0.5; polyIn.b5b = 0.5;  
    end
    if polyIn.clear == "Y"
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    if polyIn.rotaterRate != 0.0
      polyIn.rotateRate = polyIn.rotateRate + polyIn.rotaterRate
    end
    if polyIn.scalerX == 1.0 && polyIn.scalerY == 1.0 && polyIn.scalerZ == 1.0
      #do nothing
    else
      polyIn.scaleX = polyIn.scaleX + polyIn.scalerX; polyIn.scaleY = polyIn.scaleY + polyIn.scalerY; polyIn.scaleZ = polyIn.scaleZ + polyIn.scalerZ;
    end
    if polyIn.translaterX == 0.0 && polyIn.translaterY == 0.0 && polyIn.translaterZ == 0.0
      #do nothing
    else      
      polyIn.translateX = polyIn.translateX + polyIn.translaterX; polyIn.translateY = polyIn.translateY + polyIn.translaterY; polyIn.translateZ = polyIn.translateZ + polyIn.translaterZ;
    end

    if polyIn.rotateRate != 0.0
      rotateObj(polyIn.rotateRate, polyIn.rotateX, polyIn.rotateY, polyIn.rotateZ, polyIn.rotcenterX, polyIn.rotcenterY, polyIn.rotcenterZ)
    end
    if polyIn.translateX == 0.0 && polyIn.translateY == 0.0 && polyIn.translateZ == 0.0
      #do nothing
    else
      translateObj(polyIn.translateX, polyIn.translateY, polyIn.translateZ)
    end
    if polyIn.scaleX == 1.0 && polyIn.scaleY == 1.0 && polyIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(polyIn.scaleX, polyIn.scaleY, polyIn.scaleZ, polyIn.rotcenterX, polyIn.rotcenterY, polyIn.rotcenterZ)
    end
    xyzArrayInstance = []
    if polyIn.xyzArray.length.to_i > 0
      arrayIn = polyIn.xyzArray.to_s
      xyzArrayInstance = createPointArray(arrayIn)
    end
    if polyIn.vertCalc == "regPoly"
      xyzArrayInstance = regPoly(polyIn)
    end
    glBegin(GL_POLYGON)
      if polyIn.cType == "solid"
        glColor3f(polyIn.scr.to_f, polyIn.scg.to_f, polyIn.scb.to_f)
      end
      if polyIn.cType.to_s == "shader"
        displayColor(polyIn)
      end
      if xyzArrayInstance.length.to_i > 0
        numofpoints = xyzArrayInstance.length
      else  
        if polyIn.p1x != 99.0 
          xyzArrayInstance.push polyIn.p1x.to_f; xyzArrayInstance.push polyIn.p1y.to_f; xyzArrayInstance.push polyIn.p1z.to_f;
          numofpoints = 4
        end
        if polyIn.p2x != 99.0
          xyzArrayInstance.push polyIn.p2x.to_f; xyzArrayInstance.push polyIn.p2y.to_f; xyzArrayInstance.push polyIn.p2z.to_f;
          numofpoints = 6
        end
        if polyIn.p3x != 99.0   
          xyzArrayInstance.push polyIn.p4x.to_f; xyzArrayInstance.push polyIn.p3y.to_f; xyzArrayInstance.push polyIn.p3z.to_f;
          numofpoints = 9
        end
        if polyIn.p4x != 99.0
          xyzArrayInstance.push polyIn.p4x.to_f; xyzArrayInstance.push polyIn.p4y.to_f; xyzArrayInstance.push polyIn.p4z.to_f;
          numofpoints = 12
        end
        if polyIn.p5x != 99.0
          xyzArrayInstance.push polyIn.p5x.to_f; xyzArrayInstance.push polyIn.p5y.to_f; xyzArrayInstance.push polyIn.p5z.to_f;
          numofpoints = 15
        end
        if polyIn.p6x != 99.0
          xyzArrayInstance.push polyIn.p6x.to_f; xyzArrayInstance.push polyIn.p6y.to_f; xyzArrayInstance.push polyIn.p6z.to_f;
          numofpoints = 18
        end
        if polyIn.p7x != 99.0
          xyzArrayInstance.push polyIn.p7x.to_f; xyzArrayInstance.push polyIn.p7y.to_f; xyzArrayInstance.push polyIn.p7z.to_f;
          numofpoints = 21
        end
        if polyIn.p8x != 99.0
          xyzArrayInstance.push polyIn.p8x.to_f; xyzArrayInstance.push polyIn.p8y.to_f; xyzArrayInstance.push polyIn.p8z.to_f;
          numofpoints = 24
        end
        if polyIn.p9x != 99.0
          xyzArrayInstance.push polyIn.p9x.to_f; xyzArrayInstance.push polyIn.p9y.to_f; xyzArrayInstance.push polyIn.p9z.to_f;
          numofpoints = 27
        end
        if polyIn.p10x != 99.0
          xyzArrayInstance.push polyIn.p10x.to_f; xyzArrayInstance.push polyIn.p10y.to_f; xyzArrayInstance.push polyIn.p10z.to_f;
          numofpoints = 30
        end
        if polyIn.p11x != 99.0
          xyzArrayInstance.push polyIn.p11x.to_f; xyzArrayInstance.push polyIn.p11y.to_f; xyzArrayInstance.push polyIn.p11z.to_f;
          numofpoints = 33
        end
        if polyIn.p12x != 99.0
          xyzArrayInstance.push polyIn.p12x.to_f; xyzArrayInstance.push polyIn.p12y.to_f; xyzArrayInstance.push polyIn.p12z.to_f;
          numofpoints = 36
        end
        if polyIn.p13x != 99.0
          xyzArrayInstance.push polyIn.p13x.to_f; xyzArrayInstance.push polyIn.p13y.to_f; xyzArrayInstance.push polyIn.p13z.to_f;
          numofpoints = 39
        end
        if polyIn.p14x != 99.0
          xyzArrayInstance.push polyIn.p14x.to_f; xyzArrayInstance.push polyIn.p14y.to_f; xyzArrayInstance.push polyIn.p14z.to_f;
          numofpoints = 42
        end
        if polyIn.p15x != 99.0
          xyzArrayInstance.push polyIn.p15x.to_f; xyzArrayInstance.push polyIn.p15y.to_f; xyzArrayInstance.push polyIn.p15z.to_f;
          numofpoints = 45
        end
        if polyIn.p16x != 99.0
          xyzArrayInstance.push polyIn.p16x.to_f; xyzArrayInstance.push polyIn.p16y.to_f; xyzArrayInstance.push polyIn.p16z.to_f;
          numofpoints = 48
        end
      end
      if polyIn.cType.to_s == "solid"
        glColor3f(polyIn.scr.to_f, polyIn.scg.to_f, polyIn.scb.to_f)
      end
      looppoints = numofpoints.to_i-1
      for i in (0..looppoints.to_i).step(3)                          
        glVertex3f(xyzArrayInstance[i].to_f, xyzArrayInstance[i+1].to_f, xyzArrayInstance[i+2].to_f)
      end           
    glEnd()
  end
  glPopMatrix()
end

def displayCube(cubeIn)
  glPushMatrix()
  if cubeIn.action != "kill"
    if cubeIn.dim == 99.0
      cubeIn.dim = 0.5
    end
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if cubeIn.rotaterRate != 0.0
      cubeIn.rotateRate = cubeIn.rotateRate + cubeIn.rotaterRate
    end
    if cubeIn.scalerX == 1.0 && cubeIn.scalerY == 1.0 && cubeIn.scalerZ == 1.0
      #do nothing
    else
      cubeIn.scaleX = cubeIn.scaleX + cubeIn.scalerX; cubeIn.scaleY = cubeIn.scaleY + cubeIn.scalerY; cubeIn.scaleZ = cubeIn.scaleZ + cubeIn.scalerZ;
    end
    if cubeIn.translaterX == 0.0 && cubeIn.translaterY == 0.0 && cubeIn.translaterZ == 0.0
      #do nothing
    else      
      cubeIn.translateX = cubeIn.translateX + cubeIn.translaterX; cubeIn.translateY = cubeIn.translateY + cubeIn.translaterY; cubeIn.translateZ = cubeIn.translateZ + cubeIn.translaterZ;
    end

    if cubeIn.rotateRate != 0.0
      rotateObj(cubeIn.rotateRate, cubeIn.rotateX, cubeIn.rotateY, cubeIn.rotateZ, cubeIn.rotcenterX, cubeIn.rotcenterY, cubeIn.rotcenterZ)
    end
    if cubeIn.translateX == 0.0 && cubeIn.translateY == 0.0 && cubeIn.translateZ == 0.0
      #do nothing
    else
      translateObj(cubeIn.translateX, cubeIn.translateY, cubeIn.translateZ)
    end
    if cubeIn.scaleX == 1.0 && cubeIn.scaleY == 1.0 && cubeIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(cubeIn.scaleX, cubeIn.scaleY, cubeIn.scaleZ, cubeIn.rotcenterX, cubeIn.rotcenterY, cubeIn.rotcenterZ)
    end
    if cubeIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_TEXTURE_GEN_S)
      glEnable(GL_TEXTURE_GEN_T)
      glEnable(GL_TEXTURE_GEN_R)
      glEnable(GL_TEXTURE_GEN_Q)            
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon2.bmp")    
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)    
    end
    if cubeIn.cType.to_s == "solid"
      glColor3f(cubeIn.scr.to_f, cubeIn.scg.to_f, cubeIn.scb.to_f)
    end
      if cubeIn.cType.to_s == "shader"
      displayColor(cubeIn)
    end
    if cubeIn.cType.to_s == "texture" 
      glTexCoord2f(0, 0)     
      glDisable(GL_TEXTURE_GEN_S)
      glDisable(GL_TEXTURE_GEN_T)
      glDisable(GL_TEXTURE_GEN_R)
      glDisable(GL_TEXTURE_GEN_Q)                
    end
    glutSolidCube(cubeIn.dim)
    if cubeIn.wire == "Y"
      glColor3f(cubeIn.wirer.to_f, cubeIn.wireg.to_f, cubeIn.wireb.to_f)              
      glutWireCube(cubeIn.dim) 
    end
  end
  glPopMatrix()
end

def displayTeapot(teapotIn)
  glPushMatrix()
  if teapotIn.action != "kill"
    if teapotIn.dim == 99.0
      teapotIn.dim = 0.5
    end
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if teapotIn.rotaterRate != 0.0
      teapotIn.rotateRate = teapotIn.rotateRate + teapotIn.rotaterRate
    end
    if teapotIn.scalerX == 1.0 && teapotIn.scalerY == 1.0 && teapotIn.scalerZ == 1.0
      #do nothing
    else
      teapotIn.scaleX = teapotIn.scaleX + teapotIn.scalerX; teapotIn.scaleY = teapotIn.scaleY + teapotIn.scalerY; teapotIn.scaleZ = teapotIn.scaleZ + teapotIn.scalerZ;
    end
    if teapotIn.translaterX == 0.0 && teapotIn.translaterY == 0.0 && teapotIn.translaterZ == 0.0
      #do nothing
    else      
      teapotIn.translateX = teapotIn.translateX + teapotIn.translaterX; teapotIn.translateY = teapotIn.translateY + teapotIn.translaterY; teapotIn.translateZ = teapotIn.translateZ + teapotIn.translaterZ;
    end

    if teapotIn.rotateRate != 0.0
      rotateObj(teapotIn.rotateRate, teapotIn.rotateX, teapotIn.rotateY, teapotIn.rotateZ, teapotIn.rotcenterX, teapotIn.rotcenterY, teapotIn.rotcenterZ)
    end
    if teapotIn.translateX == 0.0 && teapotIn.translateY == 0.0 && teapotIn.translateZ == 0.0
      #do nothing
    else
      translateObj(teapotIn.translateX, teapotIn.translateY, teapotIn.translateZ)
    end
    if teapotIn.scaleX == 1.0 && teapotIn.scaleY == 1.0 && teapotIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(teapotIn.scaleX, teapotIn.scaleY, teapotIn.scaleZ, teapotIn.rotcenterX, teapotIn.rotcenterY, teapotIn.rotcenterZ)
    end
    if teapotIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if teapotIn.cType.to_s == "shader"
      displayColor(teapotIn)
    end
    if teapotIn.cType.to_s == "solid"
      glColor3f(teapotIn.scr.to_f, teapotIn.scg.to_f, teapotIn.scb.to_f)
    end
    if teapotIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidTeapot(teapotIn.dim)
    if teapotIn.wire == "Y"
      glColor3f(teapotIn.wirer.to_f, teapotIn.wireg.to_f, teapotIn.wireb.to_f)              
      glutWireTeapot(teapotIn.dim) 
    end
  end
  glPopMatrix()
end

def displaySphere(sphereIn)
  glPushMatrix()
  if sphereIn.action != "kill"
    if sphereIn.radius == 99.0
      sphereIn.radius = 0.4
      sphereIn.slices = 2
      sphereIn.stacks = 2
    end
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if sphereIn.rotaterRate != 0.0
      sphereIn.rotateRate = sphereIn.rotateRate + sphereIn.rotaterRate
    end
    if sphereIn.scalerX == 1.0 && sphereIn.scalerY == 1.0 && sphereIn.scalerZ == 1.0
      #do nothing
    else
      sphereIn.scaleX = sphereIn.scaleX + sphereIn.scalerX; sphereIn.scaleY = sphereIn.scaleY + sphereIn.scalerY; sphereIn.scaleZ = sphereIn.scaleZ + sphereIn.scalerZ;
    end
    if sphereIn.translaterX == 0.0 && sphereIn.translaterY == 0.0 && sphereIn.translaterZ == 0.0
      #do nothing
    else      
      sphereIn.translateX = sphereIn.translateX + sphereIn.translaterX; sphereIn.translateY = sphereIn.translateY + sphereIn.translaterY; sphereIn.translateZ = sphereIn.translateZ + sphereIn.translaterZ;
    end

    if sphereIn.rotateRate != 0.0
      rotateObj(sphereIn.rotateRate, sphereIn.rotateX, sphereIn.rotateY, sphereIn.rotateZ, sphereIn.rotcenterX, sphereIn.rotcenterY, sphereIn.rotcenterZ)
    end
    if sphereIn.translateX == 0.0 && sphereIn.translateY == 0.0 && sphereIn.translateZ == 0.0
      #do nothing
    else
      translateObj(sphereIn.translateX, sphereIn.translateY, sphereIn.translateZ)
    end
    if sphereIn.scaleX == 1.0 && sphereIn.scaleY == 1.0 && sphereIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(sphereIn.scaleX, sphereIn.scaleY, sphereIn.scaleZ, sphereIn.rotcenterX, sphereIn.rotcenterY, sphereIn.rotcenterZ)
    end
    if sphereIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if sphereIn.cType.to_s == "solid"
      glColor3f(sphereIn.scr.to_f, sphereIn.scg.to_f, sphereIn.scb.to_f)
    end
    if sphereIn.cType.to_s == "shader"
      displayColor(sphereIn)
    end
    if sphereIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidSphere(sphereIn.radius, sphereIn.slices, sphereIn.stacks)
    if sphereIn.wire == "Y"
      glColor3f(sphereIn.wirer.to_f, sphereIn.wireg.to_f, sphereIn.wireb.to_f)              
      glutWireSphere(sphereIn.radius, sphereIn.slices, sphereIn.stacks) 
    end
  end
  glPopMatrix()
end

def displayCone(coneIn)
  glPushMatrix()
  if coneIn.action != "kill"
    if coneIn.base == 99.0
      coneIn.base = 0.5
      coneIn.height = 0.7
      coneIn.slices = 2
      coneIn.stacks = 2
    end
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if coneIn.rotaterRate != 0.0
      coneIn.rotateRate = coneIn.rotateRate + coneIn.rotaterRate
    end
    if coneIn.scalerX == 1.0 && coneIn.scalerY == 1.0 && coneIn.scalerZ == 1.0
      #do nothing
    else
      coneIn.scaleX = coneIn.scaleX + coneIn.scalerX; coneIn.scaleY = coneIn.scaleY + coneIn.scalerY; coneIn.scaleZ = coneIn.scaleZ + coneIn.scalerZ;
    end
    if coneIn.translaterX == 0.0 && coneIn.translaterY == 0.0 && coneIn.translaterZ == 0.0
      #do nothing
    else      
      coneIn.translateX = coneIn.translateX + coneIn.translaterX; coneIn.translateY = coneIn.translateY + coneIn.translaterY; coneIn.translateZ = coneIn.translateZ + coneIn.translaterZ;
    end

    if coneIn.rotateRate != 0.0
      rotateObj(coneIn.rotateRate, coneIn.rotateX, coneIn.rotateY, coneIn.rotateZ, coneIn.rotcenterX, coneIn.rotcenterY, coneIn.rotcenterZ)
    end
    if coneIn.translateX == 0.0 && coneIn.translateY == 0.0 && coneIn.translateZ == 0.0
      #do nothing
    else
      translateObj(coneIn.translateX, coneIn.translateY, coneIn.translateZ)
    end
    if coneIn.scaleX == 1.0 && coneIn.scaleY == 1.0 && coneIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(coneIn.scaleX, coneIn.scaleY, coneIn.scaleZ, coneIn.rotcenterX, coneIn.rotcenterY, coneIn.rotcenterZ)
    end
    if coneIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if coneIn.cType.to_s == "solid"
      glColor3f(coneIn.scr.to_f, coneIn.scg.to_f, coneIn.scb.to_f)
    end
    if coneIn.cType.to_s == "shader"
      displayColor(coneIn)
    end    
    if coneIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidCone(coneIn.base, coneIn.height, coneIn.slices, coneIn.stacks)
    if coneIn.wire == "Y"
      glColor3f(coneIn.wirer.to_f, coneIn.wireg.to_f, coneIn.wireb.to_f)              
      glutWireCone(coneIn.base, coneIn.height, coneIn.slices, coneIn.stacks) 
    end
  end
  glPopMatrix
end

def displayTorus(torusIn)
  glPushMatrix()
  if torusIn.action != "kill"
    if torusIn.dInnerRadius == 99.0
      torusIn.dInnerRadius = 0.3
      torusIn.dOuterRadius = 0.5     
      torusIn.nSides = 3
      torusIn.nRings = 5
    end
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if torusIn.rotaterRate != 0.0
      torusIn.rotateRate = torusIn.rotateRate + torusIn.rotaterRate
    end
    if torusIn.scalerX == 1.0 && torusIn.scalerY == 1.0 && torusIn.scalerZ == 1.0
      #do nothing
    else
      torusIn.scaleX = torusIn.scaleX + torusIn.scalerX; torusIn.scaleY = torusIn.scaleY + torusIn.scalerY; torusIn.scaleZ = torusIn.scaleZ + torusIn.scalerZ;
    end
    if torusIn.translaterX == 0.0 && torusIn.translaterY == 0.0 && torusIn.translaterZ == 0.0
      #do nothing
    else      
      torusIn.translateX = torusIn.translateX + torusIn.translaterX; torusIn.translateY = torusIn.translateY + torusIn.translaterY; torusIn.translateZ = torusIn.translateZ + torusIn.translaterZ;
    end

    if torusIn.rotateRate != 0.0
      rotateObj(torusIn.rotateRate, torusIn.rotateX, torusIn.rotateY, torusIn.rotateZ, torusIn.rotcenterX, torusIn.rotcenterY, torusIn.rotcenterZ)
    end
    if torusIn.translateX == 0.0 && torusIn.translateY == 0.0 && torusIn.translateZ == 0.0
      #do nothing
    else
      translateObj(torusIn.translateX, torusIn.translateY, torusIn.translateZ)
    end
    if torusIn.scaleX == 1.0 && torusIn.scaleY == 1.0 && torusIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(torusIn.scaleX, torusIn.scaleY, torusIn.scaleZ, torusIn.rotcenterX, torusIn.rotcenterY, torusIn.rotcenterZ)
    end
    if torusIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if torusIn.cType.to_s == "solid"
      glColor3f(torusIn.scr.to_f, torusIn.scg.to_f, torusIn.scb.to_f)
    end
    if torusIn.cType.to_s == "shader"
      displayColor(torusIn)
    end    
    if torusIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidTorus(torusIn.dInnerRadius, torusIn.dOuterRadius, torusIn.nSides, torusIn.nRings)
    if torusIn.wire == "Y"
      glColor3f(torusIn.wirer.to_f, torusIn.wireg.to_f, torusIn.wireb.to_f)              
      glutWireTorus(torusIn.dInnerRadius, torusIn.dOuterRadius, torusIn.nSides, torusIn.nRings) 
    end
  end
  glPopMatrix() 
end

def displayDodecahedron(dodecahedronIn)
  glPushMatrix()
  if dodecahedronIn.action != "kill"
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if dodecahedronIn.rotaterRate != 0.0
      dodecahedronIn.rotateRate = dodecahedronIn.rotateRate + dodecahedronIn.rotaterRate
    end
    if dodecahedronIn.scalerX == 1.0 && dodecahedronIn.scalerY == 1.0 && dodecahedronIn.scalerZ == 1.0
      #do nothing
    else
      dodecahedronIn.scaleX = dodecahedronIn.scaleX + dodecahedronIn.scalerX; dodecahedronIn.scaleY = dodecahedronIn.scaleY + dodecahedronIn.scalerY; dodecahedronIn.scaleZ = dodecahedronIn.scaleZ + dodecahedronIn.scalerZ;
    end
    if dodecahedronIn.translaterX == 0.0 && dodecahedronIn.translaterY == 0.0 && dodecahedronIn.translaterZ == 0.0
      #do nothing
    else      
      dodecahedronIn.translateX = dodecahedronIn.translateX + dodecahedronIn.translaterX; dodecahedronIn.translateY = dodecahedronIn.translateY + dodecahedronIn.translaterY; dodecahedronIn.translateZ = dodecahedronIn.translateZ + dodecahedronIn.translaterZ;
    end

    if dodecahedronIn.rotateRate != 0.0
      rotateObj(dodecahedronIn.rotateRate, dodecahedronIn.rotateX, dodecahedronIn.rotateY, dodecahedronIn.rotateZ, dodecahedronIn.rotcenterX, dodecahedronIn.rotcenterY, dodecahedronIn.rotcenterZ)
    end
    if dodecahedronIn.translateX == 0.0 && dodecahedronIn.translateY == 0.0 && dodecahedronIn.translateZ == 0.0
      #do nothing
    else
      translateObj(dodecahedronIn.translateX, dodecahedronIn.translateY, dodecahedronIn.translateZ)
    end
    if dodecahedronIn.scaleX == 1.0 && dodecahedronIn.scaleY == 1.0 && dodecahedronIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(dodecahedronIn.scaleX, dodecahedronIn.scaleY, dodecahedronIn.scaleZ, dodecahedronIn.rotcenterX, dodecahedronIn.rotcenterY, dodecahedronIn.rotcenterZ)
    end
    if dodecahedronIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if dodecahedronIn.cType.to_s == "solid"
      glColor3f(dodecahedronIn.scr.to_f, dodecahedronIn.scg.to_f, dodecahedronIn.scb.to_f)
    end
    if dodecahedronIn.cType.to_s == "shader"
      displayColor(dodecahedronIn)
    end    
    if dodecahedronIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidDodecahedron()
    if dodecahedronIn.wire == "Y"
      glColor3f(dodecahedronIn.wirer.to_f, dodecahedronIn.wireg.to_f, dodecahedronIn.wireb.to_f)              
      glutWireDodecahedron() 
    end
  end
  glPopMatrix()
end

def displayIcosahedron(icosahedronIn)
  glPushMatrix()
  if icosahedronIn.action != "kill"
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if icosahedronIn.rotaterRate != 0.0
      icosahedronIn.rotateRate = icosahedronIn.rotateRate + icosahedronIn.rotaterRate
    end
    if icosahedronIn.scalerX == 1.0 && icosahedronIn.scalerY == 1.0 && icosahedronIn.scalerZ == 1.0
      #do nothing
    else
      icosahedronIn.scaleX = icosahedronIn.scaleX + icosahedronIn.scalerX; icosahedronIn.scaleY = icosahedronIn.scaleY + icosahedronIn.scalerY; icosahedronIn.scaleZ = icosahedronIn.scaleZ + icosahedronIn.scalerZ;
    end
    if icosahedronIn.translaterX == 0.0 && icosahedronIn.translaterY == 0.0 && icosahedronIn.translaterZ == 0.0
      #do nothing
    else      
      icosahedronIn.translateX = icosahedronIn.translateX + icosahedronIn.translaterX; icosahedronIn.translateY = icosahedronIn.translateY + icosahedronIn.translaterY; icosahedronIn.translateZ = icosahedronIn.translateZ + icosahedronIn.translaterZ;
    end

    if icosahedronIn.rotateRate != 0.0
      rotateObj(icosahedronIn.rotateRate, icosahedronIn.rotateX, icosahedronIn.rotateY, icosahedronIn.rotateZ, icosahedronIn.rotcenterX, icosahedronIn.rotcenterY, icosahedronIn.rotcenterZ)
    end
    if icosahedronIn.translateX == 0.0 && icosahedronIn.translateY == 0.0 && icosahedronIn.translateZ == 0.0
      #do nothing
    else
      translateObj(icosahedronIn.translateX, icosahedronIn.translateY, icosahedronIn.translateZ)
    end
    if icosahedronIn.scaleX == 1.0 && icosahedronIn.scaleY == 1.0 && icosahedronIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(icosahedronIn.scaleX, icosahedronIn.scaleY, icosahedronIn.scaleZ, icosahedronIn.rotcenterX, icosahedronIn.rotcenterY, icosahedronIn.rotcenterZ)
    end
    if icosahedronIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if icosahedronIn.cType.to_s == "solid"
      glColor3f(icosahedronIn.scr.to_f, icosahedronIn.scg.to_f, icosahedronIn.scb.to_f)
    end
    if icosahedronIn.cType.to_s == "shader"
      displayColor(icosahedronIn)
    end    
    if icosahedronIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidIcosahedron()
    if icosahedronIn.wire == "Y"
      glColor3f(icosahedronIn.wirer.to_f, icosahedronIn.wireg.to_f, icosahedronIn.wireb.to_f)              
      glutWireIcosahedron() 
    end
  end
  glPopMatrix()
end

def displayOctahedron(octahedronIn)
  glPushMatrix()
  if octahedronIn.action != "kill"
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if octahedronIn.rotaterRate != 0.0
      octahedronIn.rotateRate = octahedronIn.rotateRate + octahedronIn.rotaterRate
    end
    if octahedronIn.scalerX == 1.0 && octahedronIn.scalerY == 1.0 && octahedronIn.scalerZ == 1.0
      #do nothing
    else
      octahedronIn.scaleX = octahedronIn.scaleX + octahedronIn.scalerX; octahedronIn.scaleY = octahedronIn.scaleY + octahedronIn.scalerY; octahedronIn.scaleZ = octahedronIn.scaleZ + octahedronIn.scalerZ;
    end
    if octahedronIn.translaterX == 0.0 && octahedronIn.translaterY == 0.0 && octahedronIn.translaterZ == 0.0
      #do nothing
    else      
      octahedronIn.translateX = octahedronIn.translateX + octahedronIn.translaterX; octahedronIn.translateY = octahedronIn.translateY + octahedronIn.translaterY; octahedronIn.translateZ = octahedronIn.translateZ + octahedronIn.translaterZ;
    end

    if octahedronIn.rotateRate != 0.0
      rotateObj(octahedronIn.rotateRate, octahedronIn.rotateX, octahedronIn.rotateY, octahedronIn.rotateZ, octahedronIn.rotcenterX, octahedronIn.rotcenterY, octahedronIn.rotcenterZ)
    end
    if octahedronIn.translateX == 0.0 && octahedronIn.translateY == 0.0 && octahedronIn.translateZ == 0.0
      #do nothing
    else
      translateObj(octahedronIn.translateX, octahedronIn.translateY, octahedronIn.translateZ)
    end
    if octahedronIn.scaleX == 1.0 && octahedronIn.scaleY == 1.0 && octahedronIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(octahedronIn.scaleX, octahedronIn.scaleY, octahedronIn.scaleZ, octahedronIn.rotcenterX, octahedronIn.rotcenterY, octahedronIn.rotcenterZ)
    end
    if octahedronIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if octahedronIn.cType.to_s == "solid"
      glColor3f(octahedronIn.scr.to_f, octahedronIn.scg.to_f, octahedronIn.scb.to_f)
    end
    if octahedronIn.cType.to_s == "shader"
      displayColor(octahedronIn)
    end    
    if octahedronIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidOctahedron()
    if octahedronIn.wire == "Y"
      glColor3f(octahedronIn.wirer.to_f, octahedronIn.wireg.to_f, octahedronIn.wireb.to_f)              
      glutWireOctahedron() 
    end
  end
  glPopMatrix()
end

def displayRhombicDodecahedron(rhombicdodecahedronIn)
  glPushMatrix()
  if rhombicdodecahedronIn.action != "kill"
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if rhombicdodecahedronIn.rotaterRate != 0.0
      rhombicdodecahedronIn.rotateRate = rhombicdodecahedronIn.rotateRate + rhombicdodecahedronIn.rotaterRate
    end
    if rhombicdodecahedronIn.scalerX == 1.0 && rhombicdodecahedronIn.scalerY == 1.0 && rhombicdodecahedronIn.scalerZ == 1.0
      #do nothing
    else
      rhombicdodecahedronIn.scaleX = rhombicdodecahedronIn.scaleX + rhombicdodecahedronIn.scalerX; rhombicdodecahedronIn.scaleY = rhombicdodecahedronIn.scaleY + rhombicdodecahedronIn.scalerY; rhombicdodecahedronIn.scaleZ = rhombicdodecahedronIn.scaleZ + rhombicdodecahedronIn.scalerZ;
    end
    if rhombicdodecahedronIn.translaterX == 0.0 && rhombicdodecahedronIn.translaterY == 0.0 && rhombicdodecahedronIn.translaterZ == 0.0
      #do nothing
    else      
      rhombicdodecahedronIn.translateX = rhombicdodecahedronIn.translateX + rhombicdodecahedronIn.translaterX; rhombicdodecahedronIn.translateY = rhombicdodecahedronIn.translateY + rhombicdodecahedronIn.translaterY; rhombicdodecahedronIn.translateZ = rhombicdodecahedronIn.translateZ + rhombicdodecahedronIn.translaterZ;
    end

    if rhombicdodecahedronIn.rotateRate != 0.0
      rotateObj(rhombicdodecahedronIn.rotateRate, rhombicdodecahedronIn.rotateX, rhombicdodecahedronIn.rotateY, rhombicdodecahedronIn.rotateZ, rhombicdodecahedronIn.rotcenterX, rhombicdodecahedronIn.rotcenterY, rhombicdodecahedronIn.rotcenterZ)
    end
    if rhombicdodecahedronIn.translateX == 0.0 && rhombicdodecahedronIn.translateY == 0.0 && rhombicdodecahedronIn.translateZ == 0.0
      #do nothing
    else
      translateObj(rhombicdodecahedronIn.translateX, rhombicdodecahedronIn.translateY, rhombicdodecahedronIn.translateZ)
    end
    if rhombicdodecahedronIn.scaleX == 1.0 && rhombicdodecahedronIn.scaleY == 1.0 && rhombicdodecahedronIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(rhombicdodecahedronIn.scaleX, rhombicdodecahedronIn.scaleY, rhombicdodecahedronIn.scaleZ, rhombicdodecahedronIn.rotcenterX, rhombicdodecahedronIn.rotcenterY, rhombicdodecahedronIn.rotcenterZ)
    end
    if rhombicdodecahedronIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if rhombicdodecahedronIn.cType.to_s == "solid"
      glColor3f(rhombicdodecahedronIn.scr.to_f, rhombicdodecahedronIn.scg.to_f, rhombicdodecahedronIn.scb.to_f)
    end
    if rhombicdodecahedronIn.cType.to_s == "shader"
      displayColor(rhombicdodecahedronIn)
    end    
    if rhombicdodecahedronIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidRhombicDodecahedron()
    if rhombicdodecahedronIn.wire == "Y"
      glColor3f(rhombicdodecahedronIn.wirer.to_f, rhombicdodecahedronIn.wireg.to_f, rhombicdodecahedronIn.wireb.to_f)              
      glutWireRhombicDodecahedron() 
    end
  end
  glPopMatrix()
end

def displaySierspinskiSponge(sierspinskispongeIn)
  glPushMatrix()
  if sierspinskispongeIn.action != "kill"
    if sierspinskispongeIn.num_levels == 99
      sierspinskispongeIn.num_levels = 5
      sierspinskispongeIn.offsetX = 0.0
      sierspinskispongeIn.offsetY = 0.0
      sierspinskispongeIn.offsetZ = 0.0
      sierspinskispongeIn.spongeScale = 0.5
    end
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if sierspinskispongeIn.rotaterRate != 0.0
      sierspinskispongeIn.rotateRate = sierspinskispongeIn.rotateRate + sierspinskispongeIn.rotaterRate
    end
    if sierspinskispongeIn.scalerX == 1.0 && sierspinskispongeIn.scalerY == 1.0 && sierspinskispongeIn.scalerZ == 1.0
      #do nothing
    else
      sierspinskispongeIn.scaleX = sierspinskispongeIn.scaleX + sierspinskispongeIn.scalerX; sierspinskispongeIn.scaleY = sierspinskispongeIn.scaleY + sierspinskispongeIn.scalerY; sierspinskispongeIn.scaleZ = sierspinskispongeIn.scaleZ + sierspinskispongeIn.scalerZ;
    end
    if sierspinskispongeIn.translaterX == 0.0 && sierspinskispongeIn.translaterY == 0.0 && sierspinskispongeIn.translaterZ == 0.0
      #do nothing
    else      
      sierspinskispongeIn.translateX = sierspinskispongeIn.translateX + sierspinskispongeIn.translaterX; sierspinskispongeIn.translateY = sierspinskispongeIn.translateY + sierspinskispongeIn.translaterY; sierspinskispongeIn.translateZ = sierspinskispongeIn.translateZ + sierspinskispongeIn.translaterZ;
    end

    if sierspinskispongeIn.rotateRate != 0.0
      rotateObj(sierspinskispongeIn.rotateRate, sierspinskispongeIn.rotateX, sierspinskispongeIn.rotateY, sierspinskispongeIn.rotateZ, sierspinskispongeIn.rotcenterX, sierspinskispongeIn.rotcenterY, sierspinskispongeIn.rotcenterZ)
    end
    if sierspinskispongeIn.translateX == 0.0 && sierspinskispongeIn.translateY == 0.0 && sierspinskispongeIn.translateZ == 0.0
      #do nothing
    else
      translateObj(sierspinskispongeIn.translateX, sierspinskispongeIn.translateY, sierspinskispongeIn.translateZ)
    end
    if sierspinskispongeIn.scaleX == 1.0 && sierspinskispongeIn.scaleY == 1.0 && sierspinskispongeIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(sierspinskispongeIn.scaleX, sierspinskispongeIn.scaleY, sierspinskispongeIn.scaleZ, sierspinskispongeIn.rotcenterX, sierspinskispongeIn.rotcenterY, sierspinskispongeIn.rotcenterZ)
    end
    if sierspinskispongeIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if sierspinskispongeIn.cType.to_s == "solid"
      glColor3f(sierspinskispongeIn.scr.to_f, sierspinskispongeIn.scg.to_f, sierspinskispongeIn.scb.to_f)
    end
    if sierspinskispongeIn.cType.to_s == "shader"
      displayColor(sierspinskispongeIn)
    end    
    if sierspinskispongeIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidSierpinskiSponge(sierspinskispongeIn.num_level.to_i, test, sierspinskispongeIn.spongeScale.to_f)
    if sierpinskispongeIn.wire == "Y"
      glColor3f(sierspinskispongeIn.wirer.to_f, sierspinskispongeIn.wireg.to_f, sierspinskispongeIn.wireb.to_f)              
      glutWireSierspinskiSponge(sierspinskispongeIn.num_levels.to_i, test.to_f, sierspinskispongeIn.spongeScale.to_f) 
    end
  end
  glPopMatrix()
end

def displayTetrahedron(tetrahedronIn)
  glPushMatrix()
  if tetrahedronIn.action != "kill"
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    if tetrahedronIn.rotaterRate != 0.0
      tetrahedronIn.rotateRate = tetrahedronIn.rotateRate + tetrahedronIn.rotaterRate
    end
    if tetrahedronIn.scalerX == 1.0 && tetrahedronIn.scalerY == 1.0 && tetrahedronIn.scalerZ == 1.0
      #do nothing
    else
      tetrahedronIn.scaleX = tetrahedronIn.scaleX + tetrahedronIn.scalerX; tetrahedronIn.scaleY = tetrahedronIn.scaleY + tetrahedronIn.scalerY; tetrahedronIn.scaleZ = tetrahedronIn.scaleZ + tetrahedronIn.scalerZ;
    end
    if tetrahedronIn.translaterX == 0.0 && tetrahedronIn.translaterY == 0.0 && tetrahedronIn.translaterZ == 0.0
      #do nothing
    else      
      tetrahedronIn.translateX = tetrahedronIn.translateX + tetrahedronIn.translaterX; tetrahedronIn.translateY = tetrahedronIn.translateY + tetrahedronIn.translaterY; tetrahedronIn.translateZ = tetrahedronIn.translateZ + tetrahedronIn.translaterZ;
    end
    
    if tetrahedronIn.rotateRate != 0.0
      rotateObj(tetrahedronIn.rotateRate, tetrahedronIn.rotateX, tetrahedronIn.rotateY, tetrahedronIn.rotateZ, tetrahedronIn.rotcenterX, tetrahedronIn.rotcenterY, tetrahedronIn.rotcenterZ)
    end
    if tetrahedronIn.translateX == 0.0 && tetrahedronIn.translateY == 0.0 && tetrahedronIn.translateZ == 0.0
      #do nothing
    else
      translateObj(tetrahedronIn.translateX, tetrahedronIn.translateY, tetrahedronIn.translateZ)
    end
    if tetrahedronIn.scaleX == 1.0 && tetrahedronIn.scaleY == 1.0 && tetrahedronIn.scaleZ == 1.0
      #do nothing
    else       
      scaleObj(tetrahedronIn.scaleX, tetrahedronIn.scaleY, tetrahedronIn.scaleZ, tetrahedronIn.rotcenterX, tetrahedronIn.rotcenterY, tetrahedronIn.rotcenterZ)
    end
    if tetrahedronIn.cType == "texture"
      glEnable(GL_TEXTURE_2D)
      textureIn = Texture.new("C:/users/mojo/pictures/mojodallasicon.bmp")
      textureIn.generate
      textureIn.bind
      glColor3f(1.0, 1.0, 1.0)
    end
    if tetrahedronIn.cType.to_s == "solid"
      glColor3f(tetrahedronIn.scr.to_f, tetrahedronIn.scg.to_f, tetrahedronIn.scb.to_f)
    end
    if tetrahedronIn.cType.to_s == "shader"
      displayColor(tet)
    end    
    if tetrahedronIn.cType.to_s == "texture"
      glTexCoord2f(0, 1)                 
    end
    glutSolidTetrahedron()
    if tetrahedronIn.wire == "Y"
      glColor3f(tetrahedronIn.wirer.to_f, tetrahedronIn.wireg.to_f, tetrahedronIn.wireb.to_f)              
      glutWireTetrahedron() 
    end
  end
  glPopMatrix()
end

def reshape( width, height )  # reshape if you change window size
  ratio = width.to_f / height.to_f
  glViewport(0, 0, width, height)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glOrtho(-ratio, ratio, -1.0, 1.0, 1.0, -1.0)
  glMatrixMode(GL_MODELVIEW)
end

def keyboard( key, x, y )
  case key
  when 27 # Press ESC to exit.
    exit
  end
end

def canvas(argsIn)
  cmdArray = argsIn.split(',')
  cmdArray.each do |cmdLine|
    cmdTest = cmdLine.split(':')
    cmd = cmdTest[0].strip
    cmdVal = cmdTest.last.strip       
    case cmd.to_s
    when "screenX"
      $screenX = cmdVal
    when "screenY"
      $screenY = cmdVal
    when "posX"
      $posX = cmdVal
    when "posY"
      $posY = cmdVal
    when "title"
      $title = "'" + cmdVal.to_s + "'"
    when "blend"
      $blend = "'" + cmdVal.to_s + "'"
    when "bkr"
      $bkr = cmdVal
    when "bkg"
      $bkg = cmdVal
    when "bkb"
      $bkb = cmdVal
    when "bka"
      $bka = cmdVal                                                 
    end
  end   
  #$shape = "canvas"
  sleep 0.05  # give it time to set the global variables
end

def changeCanvas
  if $blend == "'A'"
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    glBlendEquation(GL_FUNC_ADD)
  end
  if $blend == "'C'"
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE)      
    glBlendEquation(GL_FUNC_ADD)
  end  
  if $blend == "'N'"
    glDisable(GL_BLEND)
  end
end

def commandparser (dataIn)
  
  # look at each character
  # if it is a [ then change all the , to | until you hit a ]
  arrayFlag = "N"
  i = 0
  dataIn.split("").each do |s|
    #puts "s: " + s.to_s 
    if s == "["
      arrayFlag = "Y"
    end
    if arrayFlag == "Y"
      if s == ","
        dataIn[i] = "|" # substitute a pipe for a comma in the passed array
      end
    end
    i += 1 
  end
  #puts "dataIn fixed: " + dataIn.to_s

  sid = ""
  cmdArray = dataIn.split(',')
  #puts "cmdArray: " + cmdArray.to_s
  dataCmd = ""
  cmdArray.each do |cmdLine|
    #puts "cmdLine: " + cmdLine.to_s
    cmdTest = cmdLine.split(':')
    cmd = cmdTest[0].strip
    #puts "cmd: " + cmd.to_s
    cmdVal = cmdTest.last.strip
    if cmd == "canvas"
      canvas(dataIn)
      break
    end
    case cmd.to_s
    when "vertCalc"
      cmdVal = "'" + cmdVal.to_s + "'"
    when "shape"
      cmdVal = "'" + cmdVal.to_s + "'"  
    when "cType"
      cmdVal = "'" + cmdVal.to_s + "'"
    when "title"
      cmdVal = "'" + cmdVal.to_s + "'"     
    when "texture"
      cmdVal = "'" + cmdVal.to_s + "'"          
    when "sid"
      cmdVal = "'" + cmdVal.to_s + "'"      
      sid = cmdVal.to_s
    when "clear"
      cmdVal = "'" + cmdVal.to_s + "'"  
    when "action"
      cmdVal = "'" + cmdVal.to_s + "'"       
    when "vertArray"
      cmdVal = "'" + cmdVal.to_s + "'"   
    when "wire"
      cmdVal = "'" + cmdVal.to_s + "'"
    end   
    dataCmd = dataCmd + cmd.to_s + ": " + cmdVal.to_s + ", "
  end
 
  dataCmd = "{ " + dataCmd.chop.chop + " }"
  #puts "dataCmd: " + dataCmd.to_s

  shapeTest = "N"
  shapeMatch = 0
  if $indexArray.length > 0
    i = 0
    $indexArray.each do |indexElement|     
      if indexElement.to_s == sid.to_s
        shapeTest = "Y"        
        shapeMatch = i
        break
      end
      i += 1
    end
  end 
  if shapeTest == "N"  # create bew drawArray Element
    $indexArray.push sid.to_s      
    $drawArray.push DrawObject.new(dataCmd)
  else
    $drawArray[shapeMatch.to_i] = DrawObject.new(dataCmd) #update extisting drawArray Element
  end
end  

class DrawObject

  attr_accessor :shape, :cType, :scr, :scg, :scb, :sca, :b1r, :b1g, :b1b, :b1a, :b2r, :b2g, :b2b, :b2a, :b3r, :b3g, :b3b, :b3a, :b4r, :b4g, :b4b, :b4a, :b5r, :b5g, :b5b, :b5a, :b6r, :b6g, :b6b, :b6a
  attr_accessor :b7r, :b7g, :b7b, :b7a, :b8r, :b8g, :b8b, :b8a, :b9r, :b9g, :b9b, :b9a, :b10r, :b10g, :b10b, :b10a, :b11r, :b11g, :b11b, :b11a, :b12r, :b12g, :b12b, :b12a, :b13r, :b13g, :b13b, :b13a 
  attr_accessor :b14r, :b14g, :b14b, :b14a, :b15r, :b15g, :b15b, :b15a, :b16r, :b16g, :b16b, :b16a, :wirer, :wireg, :wireb   
  attr_accessor :p1x, :p1y, :p1z, :p2x, :p2y, :p2z, :p3x, :p3y, :p3z, :p4x, :p4y, :p4z, :p5x, :p5y, :p5z, :p6x, :p6y, :p6z, :p7x, :p7y, :p7z, :p8x, :p8y, :p8z, :p9x, :p9y, :p9z
  attr_accessor :p10x, :p10y, :p10z, :p11x, :p11y, :p11z, :p12x, :p12y, :p12z, :p13x, :p13y, :p13z, :p14x, :p14y, :p14z, :p15x, :p15y, :p15z, :p16x, :p16y, :p16z, :xyzArray
  attr_accessor :numofpoints, :centerX, :centerY, :centerZ, :radius, :psize, :dataOut
  attr_accessor :screenX, :screenY, :posX, :posY, :title, :bkr, :bkg, :bkb, :bka
  attr_accessor :vertArray, :vertCalc, :numofpoints, :pntXArray, :pntYArray, :pntZArray
  attr_accessor :rotateRate, :rotRate, :rotX, :rotY, :rotZ, :rotateX, :rotateY, :rotateZ, :rotcenterX, :rotcenterY, :rotcenterZ
  attr_accessor :translateX, :translateY, :translateZ, :curX, :curY, :curZ
  attr_accessor :scaleX, :scaleY, :scaleZ, :scalecurX, :scalecurY, :scalecurZ
  attr_accessor :sid, :clear, :action, :killtimer, :killcntr, :text, :textX, :textY, :textZ, :font, :texture
  attr_accessor :dim, :wire, :slices, :stacks, :base, :height, :dInnerRadius, :dOuterRadius, :nSides, :nRings, :num_levels, :offsetX, :offsetY, :offsetZ, :spongeScale
  attr_accessor :lnum, :lposX, :lposY, :lposZ, :difr, :difg, :difb, :difa, :spcr, :spcg, :spcb, :spca, :ambr, :ambg, :ambb, :amba, :spotX, :spotY, :spotZ, :spotA, :spotcutoff, :spotexp
  attr_accessor :shininess, :emmr, :emmg, :emmb, :emma, :init, :reset, :rotaterRate, :rotaterX, :rotaterY, :rotaterZ, :scalerX, :scalerY, :scalerZ, :translaterX, :translaterY, :translaterZ

  def initialize(dataIn)

    shape = 'point'; cType = 'solid'; scr = 0.0; scg = 0.0; scb = 0.0; sca = 1.0; b1r = 0.0; b1g = 0.0; b1b = 0.0; b1a = 1.0; b2r = 0.0; b2g = 0.0; b2b = 0.0; b2a = 1.0; b3r = 0.0; b3g = 0.0; b3b = 0.0; b3a = 1.0; \
    b4r = 0.0; b4g = 0.0; b4b = 0.0; b4a = 1.0; b5r = 0.0; b5g = 0.0; b5b = 0.0; b5a = 1.0; b6r = 0.0; b6g = 0.0; b6b = 0.0; b6a = 1.0; b7r = 0.0; b7g = 0.0; b7b = 0.0; b7a = 1.0; b8r = 0.0; b8g = 0.0; b8b = 0.0; b8a = 1.0; \
    b9r = 0.0; b9g = 0.0; b9b = 0.0; b9a = 1.0; b10r = 0.0; b10g = 0.0; b10b = 0.0; b10a = 1.0; b11r = 0.0; b11g = 0.0; b11b = 0.0; b11a = 1.0; b12r = 0.0; b12g = 0.0; b12b = 0.0; b12a = 1.0; b13r = 0.0; b13g = 0.0; b13b = 0.0; b13a = 1.0; \
    b14r = 0.0; b14g = 0.0; b14b = 0.0; b14a = 1.0; b15r = 0.0; b15g = 0.0; b15b = 0.0; b15a = 1.0; b16r = 0.0; b16g = 0.0; b16b = 0.0; b16a = 1.0; wirer = 0.0; wireg = 0.0; wireb = 0.0; \
    p1x = 99.0; p1y = 99.0; p1z = 99.0; p2x = 99.0; p2y = 99.0; p2z = 99.0; p3x = 99.0; p3y = 99.0; p3z = 99.0; p4x = 99.0; p4y = 99.0; p4z = 99.0; p5x = 99.0; p5y = 99.0; p5z = 99.0; p6x = 99.0; p6y = 99.0; p6z = 99.0; \
    p7x = 99.0; p7y = 99.0; p7z = 99.0; p8x = 99.0; p8y = 99.0; p8z = 99.0; p9x = 99.0; p9y = 99.0; p9z = 99.0; p10x = 99.0; p10y = 99.0; p10z = 99.0; p11x = 99.0; p11y = 99.0; p11z = 99.0; p12x = 99.0; p12y = 99.0; p12z = 99.0; \
    p13x = 99.0; p13y = 99.0; p13z = 99.0; p14x = 99.0; p14y = 99.0; p14z = 99.0; p15x = 99.0; p15y = 99.0; p15z = 99.0; p16x = 99.0; p16y = 99.0; p16z = 99.0; xyzArray = []; \
    numofpoints = 5; centerX = 0.0; centerY = 0.0; centerZ = 0.0; radius = 0.5; psize = 1.0; dataOut = ""; \
    text = ''; textX = 0.0; textY = 0.0; textZ = 0.0; font = 'GLUT_BITMAP_9_BY_15'; texture = ""; \
    screenX = 640; screenY = 480; posX = 100; posY = 100; title = "Sonic Pi Visualizer"; bkr = 0.0; bkg = 0.0; bkb = 0.0; bka = 1.0; \
    vertArray = "N"; vertCalc = ""; numofpoints = 0; pntXArray = []; pntYArray = []; pntZArray = []; \
    rotateRate = 0.0; rotRate = 0.0; rotX = 0.0; rotY = 0.0; rotZ = 0.0; rotateX = 0.0; rotateY = 0.0; rotateZ = 0.0; rotcenterX = 0.0; rotcenterY = 0.0; rotcenterZ = 0.0; \
    translateX = 0.0; translateY = 0.0; translateZ = 0.0; curX = 0.0; curY = 0.0; curZ = 0.0; \
    scaleX = 1.0; scaleY = 1.0; scaleZ = 1.0; scalecurX = 1.0; scalecurY = 1.0; scalecurZ = 1.0; \
    sid = ""; clear = ""; action = ""; killtimer = 0.0; killcntr = 0.0; dim = 99.0; wire = "N"; slices = 0; stacks = 0; base = 99.0; height = 0.0; dInnerRadius = 99.0; dOuterRadius = 0.0; nSides = 1; nRings = 1; \
    num_levels = 99; offsetX = 0.0; offsetY = 0.0; offsetZ = 0.0; spongeScale = 0.5;
    lnum = 0; lposX = 0.0; lposY =  0.5; lposZ = -2.5; difr = 1.0; difg = 1.0; difb = 1.0; difa = 1.0; spcr = 1.0; spcg = 1.0; spcb = 1.0; spca = 1.0;
    ambr = 0.0; ambg = 0.0; ambb = 0.0; amba = 1.0; spotX = 0.0; spotY = -0.5; spotZ = 2.5; spotA = 1.0; spotcutoff = 12.0; spotexp = 1.0;
    shininess = 1.0; emmr = 0.0; emmg = 0.0; emmb = 0.0; emma = 1.0; init = 0; reset = 1; 
    rotaterRate = 0.0; rotaterX = 0.0; rotaterY = 0.0; rotaterZ = 0.0; scalerX = 0.0; scalerY = 0.0; scalerZ = 0.0; translaterX = 0.0; translaterY = 0.0; translaterZ = 0.0;

  #puts "dataIn in DrawObject: " + dataIn.to_s
  cmdArray = dataIn.split(',')
  cmdArray.each do |cmdLine|
    #puts "cmdLine: " + cmdLine.to_s
    if cmdLine[0].to_s == "{"  # get rid of beginning hash mark
      cmdLine = cmdLine[2...cmdLine.length.to_i].to_s
      #puts "cmdLine fix: " + cmdLine.to_s
    end 
    cmdTest = cmdLine.split(':')
    cmd = cmdTest[0].strip
    cmdVal = cmdTest.last.strip
    if cmdVal.include? "}"   # get rid of ending hash mark
      cmdVal = cmdVal.chop.chop
    end
    if cmd == "canvas"
      canvas(dataIn)
      break
    end
    if cmd == "init"
      initVisualizer(dataIn)
      sleep 2.0
      break
    end
    if cmd == "timesync"
      $timesync = cmdVal.to_f
      break
    end              
    case cmd.to_s
    when "shape"
      shape = cmdVal[1...-1].to_s
    when "cType"
      cType = cmdVal[1...-1].to_s
    when "scr"
      scr = cmdVal
    when "scg"
      scg = cmdVal      
    when "scb"
      scb = cmdVal
    when "sca"
      sca = cmdVal            
    when "b1r"
      b1r = cmdVal      
    when "b1g"
      b1g = cmdVal       
    when "b1b"
      b1b = cmdVal       
    when "b2r"
      b2r = cmdVal       
    when "b2g"
      b2g = cmdVal       
    when "b2b"
      b2b = cmdVal       
    when "b3r"
      b3r = cmdVal       
    when "b3g"
      b3g = cmdVal       
    when "b3b"
      b3b = cmdVal       
    when "b4r"
      b4r = cmdVal       
    when "b4g"
      b4g = cmdVal       
    when "b4b"
      b4b = cmdVal
    when "b5r"
      b5r = cmdVal       
    when "b5g"
      b5g = cmdVal       
    when "b5b"
      b5b = cmdVal
    when "b6r"
      b6r = cmdVal      
    when "b6g"
      b6g = cmdVal       
    when "b6b"
      b6b = cmdVal       
    when "b7r"
      b7r = cmdVal       
    when "b7g"
      b7g = cmdVal       
    when "b7b"
      b7b = cmdVal       
    when "b8r"
      b8r = cmdVal       
    when "b8g"
      b8g = cmdVal       
    when "b8b"
      b8b = cmdVal       
    when "b9r"
      b9r = cmdVal       
    when "b9g"
      b9g = cmdVal       
    when "b9b"
      b9b = cmdVal
    when "b10r"
      b10r = cmdVal       
    when "b10g"
      b10g = cmdVal       
    when "b10b"
      b10b = cmdVal
    when "b11r"
      b11r = cmdVal      
    when "b11g"
      b11g = cmdVal       
    when "b11b"
      b11b = cmdVal       
    when "b12r"
      b12r = cmdVal       
    when "b12g"
      b12g = cmdVal       
    when "b12b"
      b12b = cmdVal       
    when "b13r"
      b13r = cmdVal       
    when "b13g"
      b13g = cmdVal       
    when "b13b"
      b13b = cmdVal       
    when "b14r"
      b14r = cmdVal       
    when "b14g"
      b14g = cmdVal       
    when "b14b"
      b14b = cmdVal
    when "b15r"
      b15r = cmdVal       
    when "b15g"
      b15g = cmdVal       
    when "b15b"
      b15b = cmdVal
    when "b16r"
      b16r = cmdVal      
    when "b16g"
      b16g = cmdVal       
    when "wirer"
      wirer = cmdVal
    when "wireg"
      wireg = cmdVal
    when "wireb"
      wireb = cmdVal
    when "b16b"
      b16b = cmdVal                                      
    when "p1x"
      p1x = cmdVal
    when "p1y"
      p1y = cmdVal
    when "p1z"
      p1z = cmdVal
    when "p2x"
      p2x = cmdVal
    when "p2y"
      p2y = cmdVal
    when "p2z"
      p2z = cmdVal
    when "p3x"
      p3x = cmdVal
    when "p3y"
      p3y = cmdVal
    when "p3z"
      p3z = cmdVal
    when "p4x"
      p4x = cmdVal
    when "p4y"
      p4y = cmdVal
    when "p4z"
      p4z = cmdVal
    when "p5x"
      p5x = cmdVal
    when "p5y"
      p5y = cmdVal
    when "p5z"
      p5z = cmdVal
    when "p6x"
      p6x = cmdVal
    when "p6y"
      p6y = cmdVal
    when "p6z"
      p6z = cmdVal
    when "p7x"
      p7x = cmdVal
    when "p7y"
      p7y = cmdVal
    when "p7z"
      p7z = cmdVal
    when "p8x"
      p8x = cmdVal
    when "p8y"
      p8y = cmdVal
    when "p8z"
      p8z = cmdVal
    when "p9x"
      p9x = cmdVal
    when "p9y"
      p9y = cmdVal
    when "p9z"
      p9z = cmdVal
    when "p10x"
      p10x = cmdVal
    when "p10y"
      p10y = cmdVal
    when "p10z"
      p10z = cmdVal
    when "p11x"
      p11x = cmdVal
    when "p11y"
      p11y = cmdVal
    when "p11z"
      p11z = cmdVal
    when "p12x"
      p12x = cmdVal
    when "p12y"
      p12y = cmdVal
    when "p12z"
      p12z = cmdVal
    when "p13x"
      p13x = cmdVal
    when "p13y"
      p13y = cmdVal
    when "p13z"
      p13z = cmdVal
    when "p14x"
      p14x = cmdVal
    when "p14y"
      p14y = cmdVal
    when "p14z"
      p14z = cmdVal
    when "p15x"
      p15x = cmdVal
    when "p15y"
      p15y = cmdVal
    when "p15z"
      p15z = cmdVal
    when "p16x"
      p16x = cmdVal
    when "p16y"
      p16y = cmdVal
    when "p16z"
      p16z = cmdVal 
    when "psize"
      psize = cmdVal
    when "xyzArray"
      xyzArray = cmdVal
    when "vertArray"
      vertArray = cmdVal[1...-1].to_s   
    when "rotateX"
      rotateX = cmdVal.to_f
    when "rotateY"
      rotateY = cmdVal.to_f
    when "rotateZ"
      rotateZ = cmdVal.to_f
    when "rotateRate"
      rotateRate = cmdVal.to_f
    when "translateX"
      translateX = cmdVal.to_f
    when "translateY"
      translateY = cmdVal.to_f
    when "translateZ"
      translateZ = cmdVal.to_f
    when "translateRate"
      translateRate = cmdVal.to_f
    when "scaleX"
      scaleX = cmdVal.to_f
    when "scaleY"
      scaleY = cmdVal.to_f
    when "scaleZ"
      scaleZ = cmdVal.to_f
    when "timer"
      timerIn = cmdVal.to_i
    when "sid"
      sid =  cmdVal[1...-1].to_s
    when "clear"
      clear = cmdVal[1...-1].to_s
    when "action"
      action = cmdVal[1...-1].to_s
    when "vertCalc"
      vertCalc = cmdVal[1...-1].to_s
    when "numofpoints"
      numofpoints = cmdVal.to_f
    when "centerX" 
      centerX = cmdVal.to_f
    when "centerY"
      centerY = cmdVal.to_f
    when "centerZ"
      centerZ = cmdVal.to_f
    when "radius"
      radius = cmdVal.to_f
    when "killtimer"
      killtimer = cmdVal.to_f
    when "killcntr"
      killcntr = cmdVal.to_f
    when "text"
      text = cmdVal[1...-1].to_s    
    when "textX"
      textX = cmdVal.to_f
    when "textY"
      textY = cmdVal.to_f
    when "textZ"
      textZ = cmdVal.to_f
    when "font"
      font =  cmdVal[1...-1].to_s
    when "texture"
      texture = "C:/" + cmdVal[1...-1].to_s     
    when "dim"
      dim = cmdVal.to_f
    when "wire"
      wire = cmdVal[1...-1].to_s
    when "slices"
      slices = cmdVal.to_i
    when "stacks"
      stacks = cmdVal.to_i
    when "base"
      base = cmdVal.to_f
    when "height"
      height = cmdVal.to_f
    when "dInnerRadius"
      dInnerRadius = cmdVal.to_f
    when "dOuterRadius"
      dOuterRadius = cmdVal.to_f
    when "nSides"
      nSides = cmdVal.to_i
    when "nRings"
      nRings = cmdVal.to_i
    when "num_levels"
      num_levels = cmdVal.to_i
    when "offsetX"
      offsetX = cmdVal.to_f
    when "offsetY"
      offsetY = cmdVal.to_f
    when "offsetZ"
      offsetZ = cmdVal.to_f
    when "spongeScale"
      spongeScale = cmdVal.to_f
    when "lnum"
      lnum = cmdVal
    when "lposX"
      lposX = cmdVal.to_f
    when "lposY"
      lposY = cmdVal.to_f
    when "lposZ"
      lposZ = cmdVal.to_f
    when "difr"
      difr = cmdVal.to_f
    when "difg"
      difg = cmdVal.to_f
    when "difb"
      difb = cmdVal.to_f
    when "difa"
      difa = cmdVal.to_f
    when "spcr"
      spcr = cmdVal.to_f
    when "spcg"
      spcg = cmdVal.to_f
    when "spcb"
      spcb = cmdVal.to_f
    when "spca"
      spca = cmdVal.to_f
    when "ambr"
      ambr = cmdVal.to_f
    when "ambg"
      ambg = cmdVal.to_f
    when "ambb"
      ambb = cmdVal.to_f
    when "amba"
      amba = cmdVal.to_f
    when "emmr"
      emmr = cmdVal.to_f
    when "emmg"
      emmg = cmdVal.to_f
    when "emmb"
      emmb = cmdVal.to_f
    when "emma"
      emma = cmdVal.to_f
    when "shininess"
      shininess = cmdVal.to_f
    when "spotX"
      spotX = cmdVal.to_f
    when "spotY"
      spotY = cmdVal.to_f
    when "spotZ"
      spotZ = cmdVal.to_f
    when "spotA"
      spotA = cmdVal.to_f
    when "spotcutoff"
      spotcutoff = cmdVal.to_f
    when "spotexp"
      spotexp = cmdVal.to_f
    when "init"
      init = cmdVal.to_i
    when "reset"
      reset = cmdVal.to_i
    when "rotaterRate"
      rotaterRate = cmdVal.to_f
    when "rotaterX"
      rotaterX = cmdVal.to_f
    when "rotaterY"
      rotaterY = cmdVal.to_f   
    when "rotaterZ"
      rotaterZ = cmdVal.to_f                     
    when "rotcenterX"
      rotcenterX = cmdVal.to_f
    when "rotcenterY"
      rotcenterY = cmdVal.to_f  
    when "rotcenterZ"
      rotcenterZ = cmdVal.to_f                
    when "scalerX"
      scalerX = cmdVal.to_f
    when "scalerY"
      scalerY = cmdVal.to_f
    when "scalerZ"
      scalerZ = cmdVal.to_f            
    when "translaterX"
      translaterX = cmdVal.to_f
    when "translaterY"
      translaterY = cmdVal.to_f
    when "translaterZ"
      translaterZ = cmdVal.to_f            
    end    
  end

    @shape = shape; @cType = cType;
    @scr = scr; @scg = scg; @scb = scb; @sca = sca;
    @b1r = b1r; @b1g = b1g; @b1b = b1b; @b1a = b1a;
    @b2r = b1r; @b2g = b2g; @b2b = b2b; @b2a = b2a;
    @b3r = b3r; @b3g = b3g; @b3b = b3b; @b3a = b3a;
    @b4r = b4r; @b4g = b4g; @b4b = b4b; @b4a = b4a;
    @b5r = b5r; @b5g = b5g; @b5b = b5b; @b5a = b5a;
    @b6r = b6r; @b6g = b6g; @b6b = b6b; @b6a = b6a;
    @b7r = b7r; @b7g = b7g; @b7b = b7b; @b7a = b7a;
    @b8r = b8r; @b8g = b8g; @b8b = b8b; @b8a = b8a;
    @b9r = b9r; @b9g = b9g; @b9b = b9b; @b9a = b9a;
    @b10r = b10r; @b10g = b10g; @b10b = b10b; @b10a = b10a;
    @b11r = b11r; @b11g = b11g; @b11b = b11b; @b11a = b11a;
    @b12r = b12r; @b12g = b12g; @b12b = b12b; @b12a = b12a;
    @b13r = b13r; @b13g = b13g; @b13b = b13b; @b13a = b13a;
    @b14r = b14r; @b14g = b14g; @b14b = b14b; @b14a = b14a;
    @b15r = b15r; @b15g = b15g; @b15b = b15b; @b15a = b15a;
    @b16r = b16r; @b16g = b16g; @b16b = b16b; @b16a = b16a;      
    @wirer = wirer; @wireg = wireg; @wireb = wireb;
    @p1x = p1x; @p1y = p1y; @p1z = p1z;
    @p2x = p2x; @p2y = p2y; @p2z = p2z;
    @p3x = p3x; @p3y = p3y; @p3z = p3z;
    @p4x = p4x; @p4y = p4y; @p4z = p4z;
    @p5x = p5x; @p5y = p5y; @p5z = p5z;
    @p6x = p6x; @p6y = p6y; @p6z = p6z;
    @p7x = p7x; @p7y = p7y; @p7z = p7z;
    @p8x = p8x; @p8y = p8y; @p8z = p8z;
    @p9x = p9x; @p9y = p9y; @p9z = p9z;
    @p10x = p10x; @p10y = p10y; @p10z = p10z;
    @p11x = p11x; @p11y = p11y; @p11z = p11z;
    @p12x = p12x; @p12y = p12y; @p12z = p12z;
    @p13x = p13x; @p13y = p13y; @p13z = p13z;
    @p14x = p14x; @p14y = p14y; @p14z = p14z;
    @p15x = p15x; @p15y = p15y; @p15z = p15z;
    @p16x = p16x; @p16y = p16y; @p16z = p16z; @xyzArray = xyzArray;
    @numofpoints = numofpoints; @centerX = centerX; @centerY = centerY; @centerZ = centerZ; @radius = radius; @psize = psize; @dataOut = dataOut;
    @screenX = screenX; @screenY = screenY; @posX = posX; @posY = posY; @title = title; @bkr = bkr; @bkg = bkg; @bkb = bkb; @bka = bka;
    @vertArray = vertArray; @vertCalc = vertCalc; @numofpoints = numofpoints; @pntXArray = pntXArray; @pntYArray = pntYArray; @pntZArray = pntZArray; 
    @rotateRate = rotateRate; @rotRate = rotRate; @rotX = rotX; @rotY = rotY; @rotZ = rotZ; @rotateX = rotateX; @rotateY = rotateY; @rotateZ = rotateZ; @rotcenterX = rotcenterX; @rotcenterY = rotcenterY; @rotcenterZ = rotcenterZ; 
    @translateX = translateX; @translateY = translateY; @translateZ = translateZ; @curX = curX; @curY = curY; @curZ = curZ;
    @scaleX = scaleX; @scaleY = scaleY; @scaleZ = scaleZ; @scalecurX = scalecurX; @scalecurY = scalecurY; @scalecurZ = scalecurZ;
    @sid = sid; @clear = clear; @action = action; @killtimer = killtimer; @killcntr = killcntr;
    @text = text; @textX = textX; @textY = textY; @textZ = textZ; @font = font; @texture  = texture;
    @dim = dim; @wire = wire; @slices = slices; @stacks = stacks; @base = base; @height = height; @dInnerRadius = dInnerRadius; @dOuterRadius = dOuterRadius; @nSides = nSides; @nRings = nRings;
    @num_levels = num_levels; @offsetX = offsetX; @offsetY = offsetY; @offsetZ = offsetZ; @spongeScale = spongeScale;
    @lnum = lnum; @lposX = lposX;  @lposY = lposY; @lposZ = lposZ; @difr = difr; @difg = difg; @difb = difb; @difa = difa; 
    @spcr = spcr; @spcg = spcg; @spcb = spcb; @spca = spca; @ambr = ambr;  @ambg = ambg; @ambb = ambb; @amba = amba; @spotX = spotX; @spotY = spotY; @spotZ = spotZ; @spotA = spotA; @spotcutoff = spotcutoff; @spotexp = spotexp;
    @shininess = shininess; @emmr = emmr;  @emmg = emmg; @emmb = emmb; @emma = emma; @init = init; @reset = reset; 
    @rotaterRate = rotaterRate; @rotaterX = rotaterX; @rotaterY = rotaterY; @rotaterZ = rotaterZ; @scalerX = scalerX; @scalerY = scalerY; @scalerZ = scalerZ; @translaterX = translaterX; @translaterY = translaterY; @translaterZ = translaterZ;
  end 
end

def visualizer
  #puts "in Visualizer"
  t1 = Thread.new do
    glutInit([1].pack('I'), [""].pack('p'))
    glutInitDisplayMode( GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH )
    glutInitWindowSize($screenX.to_f, $screenY.to_f)
    glutInitWindowPosition($posX.to_f, $posY.to_f)
    glutCreateWindow("mojo Visualizer")
    glShadeModel(GL_SMOOTH)
    glClearDepth(1.0)
    glEnable(GL_DEPTH_TEST)  
    glDepthFunc(GL_LEQUAL)
    glEnable(GL_CULL_FACE)    
    glutDisplayFunc(GLUT.create_callback(:GLUTDisplayFunc, method(:displayShape).to_proc))
    glutReshapeFunc(GLUT.create_callback(:GLUTReshapeFunc, method(:reshape).to_proc))
    glutKeyboardFunc(GLUT.create_callback(:GLUTKeyboardFunc, method(:keyboard).to_proc))
    #glutTimerFunc(0, GLUT.create_callback(:GLUTTimerFunc, method(:timer).to_proc), 0)
    glClearColor($bkr.to_f, $bkg.to_f, $bkb.to_f, $bka.to_f)

    glEnable(GL_CULL_FACE)
    glCullFace(GL_BACK)

    #glEnable( GL_DEPTH_TEST )
    #glDepthFunc( GL_LESS )
    glEnable(GL_COLOR_MATERIAL)
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)

    glEnable( GL_NORMALIZE )

    glutMainLoop()
  end
#t1.join
end

def init
# set initial global values
  $numofpoints = 5; 
  $screenX = 640; $screenY = 480; $posX = 100; $posY = 100; $title = "Sonic Pi Visualizer"; $bkr = 0.0; $bkg = 0.0; $bkb = 0.0; $bka = 1.0;
  $drawArray = []; $indexArray = []; $pntXArray = []; $pntYArray = []; $pntZArray = []; $blend = "N"; $timesync = 0.0;
end

init

#commandparser("init, screenX: 1080, screenY: 720, posX: 10, posY: 10, bkr: 0.5, bkg: 0.5, bkb: 0.5, bka: 1.0")

commandparser("canvas, blend: N, screenX: 1080, screenY: 720, posX: 10, posY: 10, title: mojo Visualizer, bkr: 0.0, bkg: 0.0, bkb: 0.0, bka: 1.0")
#commandparser("name: blnkscrn, shape: point, scr: 1.0, scg: 0.0, scb: 0.0, p1x: 5.0, p1y: 0.1, p1z: 0.0, psize: 1.0") #pixel offscreen acts as a blank screen

#sleep 2
visualizer
sleep 1
#commandparser("sid: txt1, shape: text, text: 'This is a test', textX: 0.1, textY: 0.1, textZ: 0.0, font: 'GLUT_BITMAP_TIMES_ROMAN_24', scr: 1.0, scg: 0.0, scb: 0.0") 
#sleep 8

startServer
#sleep 2

#commandparser("sid: light0, shape: light, lnum: 0, lposX: 0.0, lposY: 0.5, lposZ: -2.5, difr: 1.0, difg: 1.0, difb: 1.0, difa: 1.0, spcr: 1.0, spcg: 1.0, spcb: 1.0, spca: 1.0, ambr: 0.0, ambg: 0.0, ambb: 0.0, amba: 1.0, spotX: 0.0, spotY: -0.5, spotZ: 2.5, spotA: 1.0, spotcutoff: 12, spotexp: 1.0 ")

#i2 = 0
#for i in 0..10
  #puts "i2: " + i2.to_s
#  if i2 < 5 
#    commandparser("sid: test1, clear: N, shape: tri, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, sca: 1.0, p1x: -0.8, p1y: -0.4, p1z: 0.0, p2x: 0.0, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0")
#  else
#    commandparser("sid: test1, action: kill, shape: tri")
#  end
#  commandparser("sid: test2, clear: N, shape: tri, cType: solid, scr: 0.0, scg: 1.0, scb: 0.0, sca: 1.0, p1x: 0.0, p1y: -0.4, p1z: 0.0, p2x: 0.8, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0") 
#  i2 += 1
#  sleep 1
#end

#commandparser("sid: point1, shape: point, scr: 1.0, scg: 0.0, scb: 0.0, p1x: 0.1, p1y: 0.1, p1z: 0.0, psize: 5.0")
#sleep 2
#commandparser("sid: point1, action: kill")

#commandparser("sid: line1, shape: line, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, p1x: 0.0, p1y: -0.4, p1z: 0.0, p2x: 0.6, p2y: -0.4, p2z: 0.0")
#sleep 2
#commandparser("sid: line1, action: kill")

#commandparser("sid: lineloop1, shape: lineloop, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, " \
#    "p1x: 0.0, p1y: 0.9, p1z: 0.0, " \
#    "p2x: -0.5, p2y: 0.7, p2z: 0.0, " \
#    "p3x: -0.7, p3y: 0.5, p3z: 0.0, " \
#    "p4x: -0.9, p4y: 0.0, p4z: 0.0, " \
#    "p5x: -0.7, p5y: -0.5, p5z: 0.0," \
#    "p6x: -0.5, p6y: -0.7, p6z: 0.0, " \
#    "p7x: 0.0, p7y: -0.9, p7z: 0.0, " \
#    "p8x: 0.5, p8y: -0.7, p8z: 0.0, " \
#    "p9x: 0.7, p9y: -0.5, p9z: 0.0, " \
#    "p10x: 0.9, p10y: 0.0, p10z: 0.0, " \
#    "p11x: 0.7, p11y: 0.5, p11z: 0.0, " \
#    "p12x: 0.5, p12y: 0.7, p12z: 0.0")
#sleep 5
#commandparser("sid: lineloop1, action: kill")

#xyzIn = [0.0, 0.9, 0.0, -0.5, 0.7, 0.0, -0.7, 0.5, 0.0, -0.9, 0.0, 0.0, -0.7, -0.5, 0.0, -0.5, -0.7, 0.0, 0.0, -0.9, 0.0, 0.5, -0.7, 0.0, 0.7, -0.5, 0.0, 0.9, 0.0, 0.0, 0.7, 0.5, 0.0, 0.5, 0.7, 0.0]
#commandparser("sid: lineloop1, shape: lineloop, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, xyzArray: " + xyzIn.to_s + '"')  
#sleep 5
#commandparser("sid: lineloop1, action: kill")

#commandparser("sid: linestrip1, shape: linestrip, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, " \
#    "p1x: 0.0, p1y: 0.9, p1z: 0.0, " \
#    "p2x: -0.5, p2y: 0.7, p2z: 0.0, " \
#    "p3x: -0.7, p3y: 0.5, p3z: 0.0, " \
#    "p4x: -0.9, p4y: 0.0, p4z: 0.0, " \
#    "p5x: -0.7, p5y: -0.5, p5z: 0.0," \
#    "p6x: -0.5, p6y: -0.7, p6z: 0.0, " \
#    "p7x: 0.0, p7y: -0.9, p7z: 0.0, " \
#    "p8x: 0.5, p8y: -0.7, p8z: 0.0, " \
#    "p9x: 0.7, p9y: -0.5, p9z: 0.0, " \
#    "p10x: 0.9, p10y: 0.0, p10z: 0.0, " \
#    "p11x: 0.7, p11y: 0.5, p11z: 0.0")
#sleep 5
#commandparser("sid: linestrip1, action: kill")
#sleep 2
#xyzIn = [0.0, 0.9, 0.0, -0.5, 0.7, 0.0, -0.7, 0.5, 0.0, -0.9, 0.0, 0.0, -0.7, -0.5, 0.0, -0.5, -0.7, 0.0, 0.0, -0.9, 0.0, 0.5, -0.7, 0.0, 0.7, -0.5, 0.0, 0.9, 0.0, 0.0, 0.7, 0.5, 0.0, 0.5, 0.7, 0.0]
#commandparser("sid: linestrip2, shape: linestrip, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, xyzArray: " + xyzIn.to_s + '"')  
#sleep 5
#commandparser("sid: linestrip2, action: kill")

#commandparser("sid: tri1, shape: tri, clear: N, cType: solid, scr: 0.0, scg: 1.0, scb: 0.0, sca: 1.0, p1x: -0.8, p1y: -0.4, p1z: 0.0, p2x: 0.8, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0") 
#sleep 5
#commandparser("sid: tri1, action: kill")

#commandparser("sid: tripstrip1, shape: tristrip, cType: solid, scr: 1.0, scg: 0.0, scb: 1.0")
#sleep 2
#commandparser("sid: tristrip1, action: kill")

#commandparser("sid: tristrip1, shape: tristrip, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, " \
#    "p1x: 0.0, p1y: 0.9, p1z: 0.0, " \
#    "p2x: -0.5, p2y: 0.7, p2z: 0.0, " \
#    "p3x: -0.7, p3y: 0.5, p3z: 0.0, " \
#    "p4x: -0.9, p4y: 0.0, p4z: 0.0, " \
#    "p5x: -0.7, p5y: -0.5, p5z: 0.0," \
#    "p6x: -0.5, p6y: -0.7, p6z: 0.0, " \
#    "p7x: 0.0, p7y: -0.9, p7z: 0.0, " \
#    "p8x: 0.5, p8y: -0.7, p8z: 0.0, " \
#    "p9x: 0.7, p9y: -0.5, p9z: 0.0, " \
#    "p10x: 0.9, p10y: 0.0, p10z: 0.0, " \
#    "p11x: 0.7, p11y: 0.5, p11z: 0.0")
#sleep 5
#commandparser("sid: tristrip1, action: kill")
#sleep 2
#commandparser("sid: tristrip2, shape: tristrip, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, xyzArray: " + xyzIn.to_s + '"')  
#sleep 5
#commandparser("sid: tristrip2, action: kill")

#commandparser("sid: quad1, shape: quad, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, sca: 1.0, p1x: -0.5, p1y: -0.5, p1z: 0.0, p2x: 0.5, p2y: -0.5, p2z: 0.0, p3x: 0.5, p3y: 0.5, p3z: 0.0, p4x: -0.5, p4y: 0.5, p4z: 0.0") 
#sleep 5
#commandparser("sid: quad1, action: kill")

#rotateRate1 = 0.0
#for i in 1..20
#commandparser("sid: quad1, shape: quad, cType: solid, rotateRate: " + rotateRate1.to_s + ", rotateX: 0.0, rotateY: 0.0, rotateZ: 1.0, rotcenterX: -0.7, rotcenterY: -0.7, rotcenterZ: 0.0, scr: 1.0, scg: 0.0, scb: 0.0, sca: 1.0, p1x: -0.9, p1y: -0.9, p1z: 0.0, p2x: -0.5, p2y: -0.9, p2z: 0.0, p3x: -0.5, p3y: -0.5, p3z: 0.0, p4x: -0.9, p4y: -0.5, p4z: 0.0") 
#rotateRate1 += 11.5
#sleep 1
#commandparser("sid: quad1, action: kill")
#end 

#commandparser("sid: quad2, shape: quad, cType: texture, texture: 'C:/Users/Michael Sutton/.sonic-pi/liveloops/gl/textures/mojoicontexture2.bmp', p1x: -0.5, p1y: -0.5, p1z: 0.0, p2x: 0.5, p2y: -0.5, p2z: 0.0, p3x: 0.5, p3y: 0.5, p3z: 0.0, p4x: -0.5, p4y: 0.5, p4z: 0.0") 
#sleep 5
#commandparser("sid: quad2, action: kill")

#commandparser("sid: poly1, shape: poly, cType: solid, vertArray: N, scr: 1.0, scg: 0.0, scb: 0.0, " \
#    "p1x: 0.0, p1y: 0.9, p1z: 0.0, " \
#    "p2x: -0.5, p2y: 0.7, p2z: 0.0, " \
#    "p3x: -0.7, p3y: 0.5, p3z: 0.0, " \
#    "p4x: -0.9, p4y: 0.0, p4z: 0.0, " \
#    "p5x: -0.7, p5y: -0.5, p5z: 0.0," \
#    "p6x: -0.5, p6y: -0.7, p6z: 0.0, " \
#    "p7x: 0.0, p7y: -0.9, p7z: 0.0, " \
#    "p8x: 0.5, p8y: -0.7, p8z: 0.0, " \
#    "p9x: 0.7, p9y: -0.5, p9z: 0.0, " \
#    "p10x: 0.9, p10y: 0.0, p10z: 0.0, " \
#    "p11x: 0.7, p11y: 0.5, p11z: 0.0, " \
#    "p12x: 0.5, p12y: 0.7, p12z: 0.0")
#sleep 5
#commandparser("sid: poly1, action: kill")
#sleep 2

#commandparser("sid: poly2, shape: poly, cType: solid, scr: 0.0, scg: 1.0, scb: 1.0, vertArray: Y, vertCalc: regPoly, numofpoints: 40, centerX: 0.0, centerY: 0.0, radius: 0.5")
#sleep 5
#commandparser("sid: poly2, action: kill")
#sleep 2

#xyzIn = [0.0, 0.9, 0.0, -0.5, 0.7, 0.0, -0.7, 0.5, 0.0, -0.9, 0.0, 0.0, -0.7, -0.5, 0.0, -0.5, -0.7, 0.0, 0.0, -0.9, 0.0, 0.5, -0.7, 0.0, 0.7, -0.5, 0.0, 0.9, 0.0, 0.0, 0.7, 0.5, 0.0, 0.5, 0.7, 0.0]
#commandparser("sid: poly3, shape: poly, cType: solid, scr: 0.0, scg: 1.0, scb: 0.0, xyzArray: " + xyzIn.to_s)
#sleep 5
#commandparser("sid: poly3, action: kill")

#commandparser("sid: cube1, shape: cube, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, wire: 'Y', wirer: 0.0, wireg: 1.0, wireb: 0.0, dim: 0.6, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: cube1, action: kill")

#commandparser("sid: teapot1, shape: teapot, cType: shader, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, dim: 0.5," \
#  "difr: 1.0, difg: 4.0, difb: 1.0, difa: 1.0, spcr: 1.0, spcg: 1.0, spcb: 1.0, spca: 1.0, ambr: 0.0, ambg: 0.0, ambb: 0.0, amba: 1.0," \
#  "shininess: 50, emmr: 0.2, emmg: 0.1, emmb: 0.1, emma 0.0, " \
#  "spotX: 0.0, spotY: 0.5, spotZ: -2.5, spotA: 1.0, spotcutoff: 15.0, spotexp: 0" ) 
#sleep 5
#commandparser("sid: teapot1, action: kill")

#commandparser("sid: sphere1, shape: sphere, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, radius: 0.5, slices: 16, stacks: 16, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: sphere1, action: kill")

#commandparser("sid: cone1, shape: cone, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, base: 0.5, height: 0.6, slices: 10, stacks: 10, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: cone1, action: kill")

#commandparser("sid: torus1, shape: torus, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'N', wirer: 0.0, wireg: 0.0, wireb: 0.0, dInnerRadius: 0.3, dOuterRadius: 0.6, nSides: 5, nRings: 5, rotateRate: 0.2, rotateX: 0.5, rotateY: 0.5, rotateZ: 0.5")
#sleep 25
#commandparser("sid: torus1, action: kill")

#commandparser("sid: dodecahedron1, shape: dodecahedron, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, rotateRate: 0.5, rotateX: 0.5, rotateY: 0.5, rotateZ: 0.5")
#sleep 15
#commandparser("sid: dodecahedronIn1, action: kill")

#commandparser("sid: icosahedron1, shape: icosahedron, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: icosahedron1, action: kill")

#commandparser("sid: octahedron1, shape: octahedron, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: octahedron1, action: kill")

#commandparser("sid: sierspinskisponge1, shape: sierspinskisponge, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, num_levels: 4, offsetX: 0.0, offsetY: 0.0, offsetZ: 0.0, spongeScale: 1, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: sierspinskisponge1, action: kill")

#commandparser("sid: tetrahedron1, shape: tetrahedron, cType: solid, scr: 0.0, scg: 0.5, scb: 0.5, wire: 'Y', wirer: 0.0, wireg: 0.0, wireb: 0.0, rotateRate: 1.0, rotateX: 1.0, rotateY: 0.5, rotateZ: 0.5")
#sleep 5
#commandparser("sid: tetrahedron1, action: kill")

#scaleX = 0.9
#scaleY = 0.9
#scaleZ = 0.9
#p1x = -0.6
#p1y = -0.4
#p1z = 0.0
#p2x =  0.6
#p2y = -0.4
#p2z = 0.0
#p3x = 0.0
#p3y = 0.6
#p3z = 0.0
#for i in 0..5
#  commandparser("sid: tri1, shape: tri, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0, p1x: " + p1x.to_s + ", p1y: " + p1y.to_s + ", p1z: " + p1z.to_s + ", p2x: " + p2x.to_s + ", p2y: " + p2y.to_s + ", p2z: " + p2z.to_s + ", p3x: " + p3x.to_s + ", p3y: " + p3y.to_s + ", p3z: " + p3z.to_s + '"')
#  sleep 2
#  commandparser("sid: tri1, action: kill")
#  sleep 0.05
#  p1x = p1x * scaleX; p1y = p1y * scaleY; p1z = p1z * scaleZ;
#  p2x = p2x * scaleX; p2y = p2y * scaleY; p2z = p2z * scaleZ;
#  p3x = p3x * scaleX; p3y = p3y * scaleY; p3z = p3z * scaleZ;
#end

#commandparser("sid: tri2, shape: tri, cType: solid, clear: Y, killtimer: 20, scr: 1.0, scg: 0.0, scb: 0.0, sca: 1.0, p1x: -0.8, p1y: -0.4, p1z: 0.0, p2x: 0.0, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0") 
#sleep 2
#commandparser("sid: tri2, shape: tri, cType: solid, clear: Y, scr: 0.0, scg: 0.0, scb: 1.0, sca: 1.0, p1x: 0.0, p1y: -0.4, p1z: 0.0, p2x: 0.8, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0") 
#sleep 2
#commandparser("sid: tri2, action: kill")

#commandparser("translateX: 0.1, translateY: 0.1, translateZ: 0.1")
#sleep 2

#commandparser("sid: txt2, shape: text, cType: solid, text: 'This is a test', textX: 0.1, textY: 0.1, textZ: 0.0, font: GLUT_BITMAP_TIMES_ROMAN_24, scr: 0.0, scg: 0.0, scb: 1.0, sca: 1.0, p1x: -0.8, p1y: -0.4, p1z: 0.0, p2x: 0.8, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0, scaleX: 0.99, scaleY: 0.99, scaleZ: 0.99") 
#sleep 2
#commandparser("sid: text1, shape: text, cType: solid, text: 'This is a test', textX: 0.1, textY: 0.1, textZ: 0.0, font: GLUT_BITMAP_TIMES_ROMAN_24, scr: 0.0, scg: 0.0, scb: 1.0, sca: 1.0, p1x: -0.8, p1y: -0.4, p1z: 0.0, p2x: 0.8, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0, translateX: .001, translateY: .001, translateZ: 0.00") 
#sleep 2
#commandparser("sid: text2, shape: text, cType: solid, text: 'This is a test', textX: 0.1, textY: 0.1, textZ: 0.0, font: GLUT_BITMAP_TIMES_ROMAN_24, scr: 0.0, scg: 0.0, scb: 1.0, sca: 1.0, p1x: -0.8, p1y: -0.4, p1z: 0.0, p2x: 0.8, p2y: -0.4, p2z: 0.0, p3x: 0.0, p3y: 0.6, p3z: 0.0, rotateRate: 1.0, rotateX: 1.00, rotateY: 0.00, rotateZ: 0.00") 
#sleep 2



#commandparser("shape: poly, cType: solid, vertArray: N")
#sleep 2
#commandparser("vertCalc: regPoly, numofpoints: 40, centerX: 0.0, centerY: 0.0, radius: 0.5")
#commandparser("shape: poly, cType: solid, scr: 1.0, scg: 0.0, scb: 0.0")
#sleep 2
#commandparser("shape: poly, cType: solid, vertArray: N")
#sleep 2
#sleep 2

#sleep 2

