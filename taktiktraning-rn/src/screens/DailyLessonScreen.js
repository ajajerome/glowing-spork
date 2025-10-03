import React, { useState, useEffect } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  Dimensions,
  TouchableOpacity,
  Animated,
  Alert
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { PanGestureHandler, State } from 'react-native-gesture-handler';
import * as Haptics from 'expo-haptics';
import FCFootballPitch from '../components/FCFootballPitch';
import DraggablePlayer from '../components/DraggablePlayer';

const { width, height } = Dimensions.get('window');

// Foundation-first: First magical scenario - "Ditt Första Mål"
// Based on research: Children need immediate success and clear feedback
const DailyLessonScreen = ({ userProfile, onNavigate }) => {
  const [currentScenario, setCurrentScenario] = useState(0);
  const [playerPosition, setPlayerPosition] = useState({ x: width/2, y: height*0.7 });
  const [hasScored, setHasScored] = useState(false);
  const [xp, setXP] = useState(userProfile?.xp || 0);
  const [showSuccess, setShowSuccess] = useState(false);

  // First 3 magical scenarios - Foundation-first design for immediate engagement
  const scenarios = [
    {
      id: 1,
      title: "Ditt Första Mål! ⚽",
      description: "Målvakten är på fel sida - spring och gör mål!",
      age_adapted: userProfile?.age?.range || '7-9',
      learning_objective: "Spatial awareness och opportunity recognition",
      setup: {
        player_start: { x: width/2, y: height*0.7 },
        goalkeeper: { x: width*0.3, y: height*0.15 }, // Wrong side!
        goal_target: { x: width*0.7, y: height*0.1 },  // Empty side
        success_zone: { x: width*0.6, y: height*0.1, radius: 40 }
      },
      success_message: "🎉 MÅÅÅL! Du såg att målvakten var på fel sida!",
      learning_explanation: "Bra jobbat! Du tittade först och såg var det var tomt. Det kallas för 'spelöversikt' - en av de viktigaste färdigheterna i fotboll!",
      xp_reward: 50,
      badge: "Första Mål",
      unlock: "Scenario 2: Hjälp din Kompis"
    },
    {
      id: 2, 
      title: "Hjälp din Kompis! 🤝",
      description: "Din kompis är fri framför mål - passa bollen!",
      learning_objective: "Teamwork och passing basics",
      setup: {
        player_start: { x: width*0.3, y: height*0.5 },
        teammate: { x: width*0.7, y: height*0.2 }, // Free in front of goal
        opponent: { x: width*0.5, y: height*0.4 }, // Blocking direct path
        success_zone: { x: width*0.7, y: height*0.2, radius: 30 }
      },
      success_message: "🎉 PERFEKT PASS! Lagarbete är nyckeln!",
      learning_explanation: "Fantastiskt! Du såg att kompisen var fri och passade bollen. I fotboll vinner laget tillsammans - inte en spelare ensam!",
      xp_reward: 50,
      badge: "Team Player",
      unlock: "Scenario 3: Försvara Målet"
    },
    {
      id: 3,
      title: "Försvara Målet! 🛡️", 
      description: "Motståndaren anfaller - stoppa dem!",
      learning_objective: "Defensive positioning",
      setup: {
        player_start: { x: width*0.5, y: height*0.3 },
        opponent: { x: width*0.5, y: height*0.6 }, // Attacking
        goal_to_defend: { x: width*0.5, y: height*0.1 },
        success_zone: { x: width*0.5, y: height*0.4, radius: 35 }
      },
      success_message: "🎉 BRILIANT FÖRSVAR! Du stoppade anfallet!",
      learning_explanation: "Perfekt positionering! Du ställde dig mellan bollen och målet. Det kallas för 'täcka' och är grunden i allt försvarsspel!",
      xp_reward: 50,
      badge: "Vägg",
      unlock: "Level 2 Unlocked!"
    }
  ];

  const currentScenarioData = scenarios[currentScenario];

  // Foundation-first: Immediate success detection
  const checkSuccess = (newPosition) => {
    const scenario = currentScenarioData;
    const successZone = scenario.setup.success_zone;
    
    const distance = Math.sqrt(
      Math.pow(newPosition.x - successZone.x, 2) + 
      Math.pow(newPosition.y - successZone.y, 2)
    );
    
    if (distance < successZone.radius && !hasScored) {
      handleSuccess();
    }
  };

  const handleSuccess = () => {
    setHasScored(true);
    setShowSuccess(true);
    
    // Immediate gratification - Duolingo style
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    
    // Award XP
    const newXP = xp + currentScenarioData.xp_reward;
    setXP(newXP);
    
    // Show success for 3 seconds, then next scenario
    setTimeout(() => {
      if (currentScenario < scenarios.length - 1) {
        nextScenario();
      } else {
        showLevelComplete();
      }
    }, 3000);
  };

  const nextScenario = () => {
    setCurrentScenario(currentScenario + 1);
    setHasScored(false);
    setShowSuccess(false);
    setPlayerPosition(scenarios[currentScenario + 1].setup.player_start);
  };

  const showLevelComplete = () => {
    Alert.alert(
      "🏆 Level 1 Complete!",
      `Grattis ${userProfile.name}! Du har lärt dig grunderna:\n\n✅ Spatial awareness\n✅ Teamwork\n✅ Defensive positioning\n\nDu har tjänat ${xp} XP och 3 badges!\n\nImorgon: Level 2 - Avancerade taktiker!`,
      [
        { text: "🎉 Fantastiskt!", onPress: () => onNavigate('progress') }
      ]
    );
  };

  const onGestureEvent = Animated.event(
    [{ nativeEvent: { translationX: 0, translationY: 0 } }],
    { useNativeDriver: false }
  );

  const onHandlerStateChange = (event) => {
    if (event.nativeEvent.state === State.END) {
      const newPosition = {
        x: playerPosition.x + event.nativeEvent.translationX,
        y: playerPosition.y + event.nativeEvent.translationY
      };
      
      setPlayerPosition(newPosition);
      checkSuccess(newPosition);
    }
  };

  return (
    <LinearGradient
      colors={['#1F5F3F', '#2E8B57', '#228B22']}
      style={styles.container}
    >
      {/* Header with XP and progress */}
      <View style={styles.header}>
        <View style={styles.xpContainer}>
          <Text style={styles.xpText}>⭐ {xp} XP</Text>
        </View>
        <View style={styles.progressIndicator}>
          <Text style={styles.progressText}>
            Scenario {currentScenario + 1} av {scenarios.length}
          </Text>
        </View>
      </View>

      {/* Scenario title and description */}
      <View style={styles.scenarioHeader}>
        <Text style={styles.scenarioTitle}>
          {currentScenarioData.title}
        </Text>
        <Text style={styles.scenarioDescription}>
          {currentScenarioData.description}
        </Text>
      </View>

      {/* FC-style football pitch */}
      <View style={styles.pitchContainer}>
        <FCFootballPitch pitchSize={userProfile?.age?.range === '7-9' ? '7v7' : '9v9'}>
          {/* Goalkeeper (opponent) */}
          <DraggablePlayer
            position={currentScenarioData.setup.goalkeeper}
            color="#FF4444"
            number="1"
            size={25}
            draggable={false}
          />
          
          {/* Teammate (if scenario has one) */}
          {currentScenarioData.setup.teammate && (
            <DraggablePlayer
              position={currentScenarioData.setup.teammate}
              color="#4444FF"
              number="10"
              size={20}
              draggable={false}
            />
          )}
          
          {/* User's player (draggable) */}
          <PanGestureHandler
            onGestureEvent={onGestureEvent}
            onHandlerStateChange={onHandlerStateChange}
          >
            <Animated.View>
              <DraggablePlayer
                position={playerPosition}
                color="#FFD700"
                number="7"
                size={25}
                draggable={true}
                isUser={true}
              />
            </Animated.View>
          </PanGestureHandler>
          
          {/* Success zone indicator (subtle) */}
          {!hasScored && (
            <View
              style={[
                styles.successZone,
                {
                  left: currentScenarioData.setup.success_zone.x - 20,
                  top: currentScenarioData.setup.success_zone.y - 20,
                }
              ]}
            />
          )}
        </FCFootballPitch>
      </View>

      {/* Instructions */}
      <View style={styles.instructionsContainer}>
        <Text style={styles.instructionsText}>
          💡 Dra den gula spelaren (det är du!) för att lösa situationen
        </Text>
      </View>

      {/* Success overlay */}
      {showSuccess && (
        <View style={styles.successOverlay}>
          <LinearGradient
            colors={['rgba(255,215,0,0.95)', 'rgba(255,165,0,0.95)']}
            style={styles.successContent}
          >
            <Text style={styles.successTitle}>
              {currentScenarioData.success_message}
            </Text>
            <Text style={styles.successXP}>
              +{currentScenarioData.xp_reward} XP
            </Text>
            <Text style={styles.successBadge}>
              🏅 {currentScenarioData.badge}
            </Text>
            <Text style={styles.successExplanation}>
              {currentScenarioData.learning_explanation}
            </Text>
            <Text style={styles.successNext}>
              {currentScenarioData.unlock}
            </Text>
          </LinearGradient>
        </View>
      )}
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 10,
  },
  xpContainer: {
    backgroundColor: 'rgba(255,215,0,0.2)',
    borderRadius: 20,
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderWidth: 2,
    borderColor: '#FFD700',
  },
  xpText: {
    color: '#FFD700',
    fontSize: 16,
    fontWeight: 'bold',
  },
  progressIndicator: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 15,
    paddingHorizontal: 12,
    paddingVertical: 6,
  },
  progressText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  scenarioHeader: {
    alignItems: 'center',
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  scenarioTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginBottom: 10,
  },
  scenarioDescription: {
    fontSize: 18,
    color: 'rgba(255,255,255,0.9)',
    textAlign: 'center',
    lineHeight: 24,
  },
  pitchContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  instructionsContainer: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    marginHorizontal: 20,
    marginBottom: 30,
    borderRadius: 15,
    padding: 15,
  },
  instructionsText: {
    color: 'white',
    fontSize: 16,
    textAlign: 'center',
    fontWeight: '500',
  },
  successZone: {
    position: 'absolute',
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,215,0,0.3)',
    borderWidth: 2,
    borderColor: 'rgba(255,215,0,0.6)',
    borderStyle: 'dashed',
  },
  successOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.7)',
  },
  successContent: {
    borderRadius: 25,
    padding: 30,
    marginHorizontal: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.3,
    shadowRadius: 20,
    elevation: 10,
  },
  successTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2E8B57',
    textAlign: 'center',
    marginBottom: 15,
  },
  successXP: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FF6B35',
    marginBottom: 10,
  },
  successBadge: {
    fontSize: 20,
    marginBottom: 15,
  },
  successExplanation: {
    fontSize: 16,
    color: '#2E8B57',
    textAlign: 'center',
    lineHeight: 22,
    marginBottom: 15,
  },
  successNext: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1F5F3F',
    textAlign: 'center',
  },
});

export default DailyLessonScreen;