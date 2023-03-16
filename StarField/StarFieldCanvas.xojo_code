#tag Class
Protected Class StarFieldCanvas
Inherits DesktopCanvas
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
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
		      
		      // Determine the distance of this star from us (0 = no distance, 1 = maximum distance).
		      Var distance As Double = s.Z / Z_MAX
		      
		      // We want close stars to be brighter than distant stars so we'll adjust the alpha.
		      g.DrawingColor = Color.RGB(255, 255, 255, 255 * distance)
		      
		      // Draw the star as a 1 x 1 pixel square.
		      g.FillRectangle(x, y, 1, 1)
		    Next s
		  End If
		  
		  // Raise the Paint event.
		  Paint(g, areas)
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0, Description = 52657475726E732054727565206966207468652063616E6176732069732063757272656E746C7920616E696D6174696E67207468652073746172206669656C642E
		Function Animating() As Boolean
		  /// Returns True if the canavs is currently animating the star field.
		  
		  If mAnimationTimer = Nil Or Not mAnimationTimer.Enabled Then
		    Return False
		  Else
		    Return True
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 55706461746573207468652063616E7661732E2043616C6C6564207768656E65766572206F75722060416E696D6174696F6E54696D6572602066697265732E
		Private Sub AnimationTimerActionDelegate(sender As Timer)
		  /// Updates the canvas. Called whenever our `AnimationTimer` fires.
		  
		  #Pragma Unused sender
		  
		  Self.Refresh
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652063757272656E7420746172676574206672616D657320706572207365636F6E642E
		Function FPS() As Integer
		  /// Returns the current target frames per second.
		  
		  Return mFPS
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 536574732074686520746172676574206672616D657320706572207365636F6E642028692E653A20746865206E756D626572206F662074696D6573
		Sub FPS(Assigns fps As Integer)
		  /// Sets the target frames per second (i.e: the number of times 
		  // to repaint the canvas per second).
		  
		  mFPS = fps
		  If mAnimationTimer <> Nil Then mAnimationTimer.Period = 1000/mFPS
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 4D6F766573206576657279207374617220636C6F73657220746F207468652076616E697368696E6720706F696E74206279206064697374616E63656020706978656C732E
		Protected Sub MoveStars(distance As Integer)
		  /// Moves every star closer to the vanishing point by `distance` pixels.
		  ///
		  /// To move a star closer to us, we decrease its Z coordinate. 0 is at the viewer.
		  
		  For Each s As StarField.Star In Stars
		    s.Z = s.Z - distance
		    
		    // Once a star reaches the reaching the vanishing point (z = 0), we send it 
		    // back so it can keep coming at us again.
		    // If s.Z <= 0 Then s.Z = STAR_COUNT - 1
		    If s.Z <= 0 Then s.Z = MAX_DISTANCE
		  Next s
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 496E697469616C6973657320746865206053746172736020617272617920616E642072616E646F6D69736573207468652073746172206C6F636174696F6E732E
		Protected Sub RandomiseStarLocations()
		  /// Initialises the `Stars` array and randomises the star locations.
		  
		  // Randomly set the position of the stars.
		  Stars.ResizeTo(-1)
		  For i As Integer = 0 To STAR_COUNT - 1
		    stars.Add(New Star(System.Random.InRange(X_MIN, X_MAX), _
		    System.Random.InRange(Y_MIN, Y_MAX), _
		    System.Random.InRange(0, Z_MAX)))
		  Next i
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E73207468652063757272656E74206E756D626572206F6620706978656C7320746861742065616368207374617220616476616E63657320706572207570646174652E
		Function StarSpeed() As Integer
		  /// Returns the current number of pixels that each star advances per update.
		  
		  Return mStarSpeed
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 536574732074686520607370656564602028696E20706978656C7329207468617420746865207374617273206D6F76652061742E
		Sub StarSpeed(Assigns speed As Integer)
		  /// Sets the `speed` (in pixels) that the stars move at. 
		  ///
		  /// `speed` is the number of pixels to advance each star towards the 
		  /// vanishing point per update. A value of 5 - 10 works well.
		  
		  mStarSpeed = speed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5374617274732074686520616E696D6174696F6E20776974682061207461726765742060667073602C206D6F76696E6720656163682073746172206073706565646020706978656C7320706572207570646174652E
		Sub Start(fps As Integer = 30, speed As Double = 5)
		  /// Starts the animation with a target `fps`, moving each star `speed` pixels per update.
		  
		  // Cache the FPS value.
		  mFPS = fps
		  
		  // Store the star speed. This will be needed later by the `MoveStars()` method.
		  mStarSpeed = speed
		  
		  // Create the stars and the cached colour arrays.
		  RandomiseStarLocations
		  
		  // Initialise the timer and kick it off.
		  mAnimationTimer = New Timer
		  AddHandler mAnimationTimer.Action, AddressOf AnimationTimerActionDelegate
		  mAnimationTimer.Period = 1000 / mFPS
		  mAnimationTimer.RunMode = Timer.RunModes.Multiple
		  mAnimationTimer.Enabled = True
		  
		  // Flag that the stars should be drawn on every repaint of the canvas.
		  StarsNeedDrawing = True
		  
		  // Force a canvas update.
		  Self.Refresh
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 53746F7073207468652073746172206669656C6420616E696D6174696F6E2E
		Sub Stop()
		  /// Stops the star field animation.
		  
		  // Stop the timer. This will stop the periodic canvas refresh.
		  mAnimationTimer.Enabled = False
		  
		  // Free the memory used by the Stars array.
		  Stars.ResizeTo(-1)
		  
		  StarsNeedDrawing = False
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0, Description = 5468652063616E76617320686173206A7573742072657061696E7465642E
		Event Paint(g As Graphics, areas() As Rect)
	#tag EndHook


	#tag Property, Flags = &h21, Description = 526573706F6E7369626C6520666F72207570646174696E67207468652063616E766173206174206120726567756C617220696E74657276616C2E
		Private mAnimationTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 5468652063616E7661732720757064617465206672657175656E637920286672616D657320706572207365636F6E64292E
		Private mFPS As Integer = 30
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 546865206E756D626572206F6620706978656C7320746865207374617220616476616E636520746F207468652076616E697368696E6720706F696E7420706572207570646174652E
		Private mStarSpeed As Integer
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 4F7572206172726179206F662073746172732E
		Private Stars() As Star
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 49662054727565207468656E207768656E207468652063616E766173207265667265736865732C2069742077696C6C2064726177207468652073746172732E
		Private StarsNeedDrawing As Boolean = False
	#tag EndProperty


	#tag Constant, Name = MAX_DISTANCE, Type = Double, Dynamic = False, Default = \"500", Scope = Protected, Description = 546865206D6178696D756D2064697374616E6365206120737461722063616E20617761792066726F6D20746865207669657765722E
	#tag EndConstant

	#tag Constant, Name = STAR_COUNT, Type = Double, Dynamic = False, Default = \"5000", Scope = Protected, Description = 546865206E756D626572206F6620737461727320746F20686F6C6420696E206F75722061727261792E
	#tag EndConstant

	#tag Constant, Name = X_MAX, Type = Double, Dynamic = False, Default = \"800", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = X_MIN, Type = Double, Dynamic = False, Default = \"-800", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Y_MAX, Type = Double, Dynamic = False, Default = \"450", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Y_MIN, Type = Double, Dynamic = False, Default = \"-450", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Z_MAX, Type = Double, Dynamic = False, Default = \"1000", Scope = Protected, Description = 546865206D6178696D756D2064697374616E6365206120737461722063616E2062652066726F6D20746865207669657765722028696E20706F696E7473292E
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
	#tag EndViewBehavior
End Class
#tag EndClass
