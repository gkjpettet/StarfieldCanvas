#tag Class
Protected Class StarFieldCanvas
Inherits Canvas
	#tag Event
		Sub Paint(g As Graphics, areas() As REALbasic.Rect)
		  #Pragma Unused areas
		  
		  // Start with a black background.
		  g.DrawingColor = Color.Black
		  g.FillRectangle(0, 0, me.Width, me.Height)
		  
		  // Only draw the star field if animation is enabled.
		  If StarsNeedDrawing Then
		    // Move the stars towards the view point.
		    MoveStars(mStarSpeed)
		    
		    // Cache the canvas dimensions.
		    Var w As Double = g.Width
		    Var h As Double = g.Height
		    Var halfWidth As Double = g.Width / 2
		    Var halfHeight As Double = g.Height / 2
		    
		    // Calculate the screen position of every star.
		    For Each s As Star In Stars
		      Var x As Double = halfWidth + s.X / (s.Z * 0.001)
		      Var y As Double = halfHeight + s.Y / (s.Z * 0.001)
		      
		      // Don't draw the star if it's not currently visible.
		      If x < 0 Or x >= w Or y < 0 Or y >= h Then Continue
		      
		      // Determine the distance of this star from us.
		      Var distance As Double = s.Z / 1000
		      
		      // We want close stars to be brighter than distant stars.
		      // Calculate the correct color to use for this star (range 0-9.= where 0 = bright, 9 = faint).
		      // This will be the index of the colour in the `WhiteColours` array.
		      g.DrawingColor = WhiteColours(9 * (distance * distance))
		      
		      // Draw the star as a 1 x 1 pixel square.
		      g.FillRectangle(x, y, 1, 1)
		    Next s
		  End If
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0, Description = 52657475726E732054727565206966207468652063616E7661732069732063757272656E746C7920616E696D6174696E67207468652073746172206669656C642E
		Function Animating() As Boolean
		  ///
		  ' Returns True if the canavs is currently animating the star field.
		  ///
		  
		  If AnimationTimer = Nil Or Not AnimationTimer.Enabled Then
		    Return False
		  Else
		    Return True
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 412064656C6567617465206D6574686F64207468617420697320696E766F6B6564207768656E65766572207468652060416E696D6174696F6E54696D6572602066697265732E
		Private Sub AnimationTimerActionDelegate(sender As Timer)
		  ///
		  ' Updates the canvas.
		  ' Called whenever our `AnimationTimer` fires.
		  ///
		  
		  #Pragma Unused sender
		  
		  Self.Invalidate
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652063757272656E7420746172676574206672616D657320706572207365636F6E642E
		Function FPS() As Integer
		  ///
		  ' Returns the current target frames per second.
		  ///
		  
		  Return mFPS
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 536574732074686520746172676574206672616D657320706572207365636F6E64
		Sub FPS(Assigns fps As Integer)
		  ///
		  ' Sets the target frames per second (i.e: the number of times 
		  ' to repaint the canvas per second).
		  ///
		  
		  
		  mFPS = fps
		  If AnimationTimer <> Nil Then AnimationTimer.Period = 1000/mFPS
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 496E697469616C69736573207468652063616E76617320666F72206669727374207573652E2043616C6C656420696E7465726E616C6C7920627920605374617274602E
		Private Sub Initialise()
		  ///
		  ' Initialises the canvas for first use.
		  ' Called internally by `Start(Double)`.
		  ///
		  
		  // Randomly set the position of the stars.
		  Stars.ResizeTo(-1)
		  For i As Integer = 0 To STAR_COUNT - 1
		    stars.AddRow(New Star(System.Random.InRange(X_MIN, X_MAX), _
		    System.Random.InRange(Y_MIN, Y_MAX), _
		    System.Random.InRange(Z_MIN, Z_MAX)))
		  Next i
		  
		  // Create the 10 levels of white colour.
		  WhiteColours.ResizeTo(-1)
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 0)) // Brightest.
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 25))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 50))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 75))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 100))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 125))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 150))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 175))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 200))
		  WhiteColours.AddRow(Color.RGBA(255, 255, 255, 225)) // Faintest.
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 4D6F766573206576657279207374617220636C6F73657220746F207468652076616E697368696E6720706F696E742062792074686520737065636966696564206E756D626572206F6620706978656C732E
		Private Sub MoveStars(distance As Double)
		  ///
		  ' Moves every star closer to the vanishing point.
		  ' To move a star closer to us, we decrease its Z index.
		  '
		  ' - Parameter distance: How many pixels to move a star each update.
		  ///
		  
		  Var limit As Integer = STAR_COUNT - 1
		  
		  For Each s As Star In Stars
		    s.Z = s.Z - distance
		    
		    // Once a star comes close to reaching the vanishing point, we send it 
		    // back so it can keep coming at us again.
		    While s.Z <= 1
		      s.Z = s.Z + limit
		    Wend
		  Next s
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652063757272656E74206E756D626572206F6620706978656C7320746861742065616368207374617220616476616E63657320706572207570646174652E
		Function StarSpeed() As Integer
		  ///
		  ' Returns the current number of pixels that each star advances per update.
		  '
		  ' - Returns: Integer (pixels).
		  ///
		  
		  Return mStarSpeed
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5365747320746865207370656564207468617420746865207374617273206D6F76652061742E20412076616C7565206F6620312D313020776F726B732077656C6C2E
		Sub StarSpeed(Assigns speed As Integer)
		  ///
		  ' Sets the speed that the stars move at. 
		  ' 
		  ' - Parameter speed: The number of pixels to advance each star towards the 
		  '                    vanishing point per update. A value of 5 - 10 works well.
		  
		  mStarSpeed = speed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5374617274732074686520616E696D6174696F6E2C206D6F76696E6720746865207374617273206073706565646020706978656C7320706572207570646174652E20412076616C7565206F6620312D313020776F726B732077656C6C2E
		Sub Start(fps As Integer = 30, speed As Double = 5)
		  ///
		  ' Starts the animation.
		  '
		  ' - Parameter fps: The target FPS (i.e: the number of times per second to update the canvas).
		  ' - Parameter speed: The number of pixels to move each star each update.
		  ///
		  
		  // Cache the FPS value.
		  mFPS = fps
		  
		  // Store the star speed. This will be needed later by the `MoveStars` method.
		  mStarSpeed = speed
		  
		  // Create the stars and the cached colour arrays.
		  Initialise
		  
		  // Initialise the timer and kick it off.
		  AnimationTimer = New Timer
		  AddHandler AnimationTimer.Action, AddressOf AnimationTimerActionDelegate
		  AnimationTimer.Period = 1000/mFPS
		  AnimationTimer.RunMode = Timer.RunModes.Multiple
		  AnimationTimer.Enabled = True
		  
		  // Flag that the stars should be drawn on every repaint of the canvas.
		  StarsNeedDrawing = True
		  
		  // Force a canvas update.
		  Self.Invalidate
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 53746F70732074686520616E696D6174696F6E2E
		Sub Stop()
		  ///
		  ' Stops the star field animation.
		  ///
		  
		  // Stop the timer. This will stop the periodic canvas refresh.
		  AnimationTimer.Enabled = False
		  
		  // Free the memory used by the Stars and WhiteColours arrays.
		  Stars.ResizeTo(-1)
		  WhiteColours.ResizeTo(-1)
		  
		  StarsNeedDrawing = False
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private AnimationTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFPS As Integer = 30
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStarSpeed As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Stars() As Star
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 49662054727565207468656E207768656E207468652063616E766173207265667265736865732C2069742077696C6C2064726177207468652073746172732E
		Private StarsNeedDrawing As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 436F6E7461696E7320776869746520436F6C6F7220696E7374616E636573206F662064656372656173696E67206272696768746E6573732028696E6465782030203D206272696768742C2039203D2076657279206661696E7429
		Private WhiteColours() As Color
	#tag EndProperty


	#tag Constant, Name = STAR_COUNT, Type = Double, Dynamic = False, Default = \"750", Scope = Private, Description = 546865206E756D626572206F6620737461727320746F20686F6C6420696E206F75722061727261792E
	#tag EndConstant

	#tag Constant, Name = X_MAX, Type = Double, Dynamic = False, Default = \"800", Scope = Private
	#tag EndConstant

	#tag Constant, Name = X_MIN, Type = Double, Dynamic = False, Default = \"-800", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Y_MAX, Type = Double, Dynamic = False, Default = \"450", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Y_MIN, Type = Double, Dynamic = False, Default = \"-450", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Z_MAX, Type = Double, Dynamic = False, Default = \"1000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Z_MIN, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Tooltip"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocus"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowTabs"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Transparent"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Visible=false
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			Visible=false
			Group=""
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
