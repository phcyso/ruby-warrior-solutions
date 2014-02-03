class Player
 	DEBUG_ON ||= true
	def DEBUG message 
		p message if DEBUG_ON
	end

###########################
#Play_turn, where the magic happens.
###########################
	def play_turn(warrior)
		#set global variables for warrior for the other def's
    @warrior = warrior
    
		set_variables warrior

    #All the below variables will return true if they do a ! action
		heal || run ||shoot_back|| attack || rescue_captive || turn || walk
		
    #set health to track is we are being hurt
		@health = warrior.health
  	end

  def set_variables(warrior)
    #set health variables if first turn
		@health ||= warrior.health
		@MAX_HEALTH ||= warrior.health #Max health is always 20, but i like to set it like this incase it changes in a future version of rubywarrior

		#set state variables
		@running_away ||= false
  end

###########################
# the below functions are all actions.
###########################
  def walk
  		@warrior.walk!
  	end
  	

 	def heal
 		if safe? 
 			@warrior.rest! # Rest until no longer hurt.      
      @running_away = false if @warrior.health >= @MAX_HEALTH
      DEBUG "Warrior was healed, Previous health: #{@health}, Current Health: #{@warrior.health}"
 			return true
 		else
 			return false
 		end
 	end

  	def attack
    each_direction do |dir|
      if @warrior.feel(dir).enemy?
        DEBUG "Attacking enemy in direction: #{dir.to_s}"
        @warrior.attack!(dir)
        return true
      end
    end
    false
  	end

  	def rescue_captive
	    each_direction do |dir|
      if @warrior.feel(dir).captive?
        DEBUG "Rescueing captive in direction: #{dir.to_s}"
        @warrior.rescue!(dir)
        return true
      end
    end
    false
  	end

    def shoot_back
      each_direction do |dir|
        if long_range_enemy_in_view?(dir)
          DEBUG "Can see Enemy in #{dir}, shooting them."
          @warrior.shoot! dir
          return true
        end
      end
      return false
    end
  
  def turn
    if nothing_but_wall?(:forward)
    @warrior.pivot!
   return true 
  end
    return false
  end

  def run
    if safe? && low_health?
      DEBUG "RUNNING AWAY! health:#{@warrior.health}"
      @warrior.walk!(:backward)
      return true
    end
      return false
  end
	
###########################
# go through each direction, i think there is a better way to handle these. 
###########################
  def each_direction(&block)
      [:forward, :backward].each do |dir|
      yield(dir)
      end
  end
###########################
#the below functions mostly return true or false, used by the above functions
###########################

  	def under_attack?
  		DEBUG "Warrior is under attack? :#{(@warrior.health < @health)}"
  		(@warrior.health < @health)
  	end

    def nothing_but_wall?(direction)
 #    ob = objects_in_view(direction)                   # Walls count as empty space so the objects_in_view
 #    return false if ob.first.nil?                     #  function will not curently return them.
 #     ob.first && ob.first.wall? && !ob.first.stairs?  #  
 
       @warrior.feel.wall?
    end
    
    def low_health?
      (@warrior.health < (@MAX_HEALTH / 2))
    end

    def long_range_enemy_in_view?(direction)
      ob = objects_in_view(direction)
      ob.first && ob.first.enemy? && %{a w}.include?(ob.first.character)
    end

  def objects_in_view(direction)
    @warrior.look(direction).select { |space|   !space.empty?  } 
  end
  
  def safe?
 		(@health < @MAX_HEALTH) && !under_attack? && (!long_range_enemy_in_view?(:forward) && !long_range_enemy_in_view?(:backward) )
 	end
end
