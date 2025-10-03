import React, { useState } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  StyleSheet, 
  Dimensions,
  TextInput,
  Alert
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import * as Haptics from 'expo-haptics';

const { width, height } = Dimensions.get('window');

// Foundation-first onboarding: Hook them in 30 seconds
const OnboardingScreen = ({ onComplete }) => {
  const [step, setStep] = useState(1);
  const [profile, setProfile] = useState({
    name: '',
    age: null,
    position: null,
    experience: null
  });

  const ageGroups = [
    { range: '7-9', label: '7-9 år', emoji: '🌟', description: 'Mini Champions' },
    { range: '10-12', label: '10-12 år', emoji: '⚽', description: 'Tactical Minds' },
    { range: '13-16', label: '13-16 år', emoji: '🏆', description: 'Academy Level' }
  ];

  const positions = [
    { id: 'forward', name: 'Anfallare', emoji: '⚡', description: 'Gör mål!' },
    { id: 'midfielder', name: 'Mittfältare', emoji: '🎯', description: 'Styr spelet!' },
    { id: 'defender', name: 'Försvarare', emoji: '🛡️', description: 'Stoppa motståndaren!' },
    { id: 'goalkeeper', name: 'Målvakt', emoji: '🥅', description: 'Rädda målet!' }
  ];

  const handleNext = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    
    if (step < 3) {
      setStep(step + 1);
    } else {
      // Complete onboarding
      onComplete(profile);
    }
  };

  const selectAge = (ageGroup) => {
    setProfile({ ...profile, age: ageGroup });
    setTimeout(handleNext, 500); // Auto-advance after selection
  };

  const selectPosition = (position) => {
    setProfile({ ...profile, position: position });
    setTimeout(handleNext, 500); // Auto-advance after selection
  };

  const renderStep1 = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.title}>⚽ Välkommen till TaktikTräning!</Text>
      <Text style={styles.subtitle}>Duolingo för Fotboll</Text>
      <Text style={styles.description}>
        Lär dig fotbollstaktik på 5 minuter om dagen!
      </Text>
      
      <View style={styles.inputContainer}>
        <Text style={styles.inputLabel}>Vad heter du?</Text>
        <TextInput
          style={styles.textInput}
          placeholder="Skriv ditt namn här..."
          placeholderTextColor="rgba(255,255,255,0.6)"
          value={profile.name}
          onChangeText={(name) => setProfile({ ...profile, name })}
          autoCapitalize="words"
        />
      </View>

      <TouchableOpacity 
        style={[styles.button, !profile.name && styles.buttonDisabled]}
        onPress={handleNext}
        disabled={!profile.name}
      >
        <Text style={styles.buttonText}>Nästa →</Text>
      </TouchableOpacity>
    </View>
  );

  const renderStep2 = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.title}>Hej {profile.name}! 👋</Text>
      <Text style={styles.subtitle}>Hur gammal är du?</Text>
      
      <View style={styles.optionsContainer}>
        {ageGroups.map((age, index) => (
          <TouchableOpacity
            key={index}
            style={[
              styles.optionCard,
              profile.age?.range === age.range && styles.optionCardSelected
            ]}
            onPress={() => selectAge(age)}
          >
            <Text style={styles.optionEmoji}>{age.emoji}</Text>
            <Text style={styles.optionTitle}>{age.label}</Text>
            <Text style={styles.optionDescription}>{age.description}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );

  const renderStep3 = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.title}>Vilken position gillar du? ⚽</Text>
      <Text style={styles.subtitle}>Välj din favoritposition på planen</Text>
      
      <View style={styles.optionsContainer}>
        {positions.map((pos, index) => (
          <TouchableOpacity
            key={index}
            style={[
              styles.optionCard,
              styles.positionCard,
              profile.position?.id === pos.id && styles.optionCardSelected
            ]}
            onPress={() => selectPosition(pos)}
          >
            <Text style={styles.optionEmoji}>{pos.emoji}</Text>
            <Text style={styles.optionTitle}>{pos.name}</Text>
            <Text style={styles.optionDescription}>{pos.description}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );

  const renderStep4 = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.title}>🎉 Perfekt, {profile.name}!</Text>
      <Text style={styles.subtitle}>Du är redo att börja din fotbollsresa!</Text>
      
      <View style={styles.summaryContainer}>
        <Text style={styles.summaryText}>
          📊 Din profil:
        </Text>
        <Text style={styles.summaryDetail}>
          👤 Namn: {profile.name}
        </Text>
        <Text style={styles.summaryDetail}>
          🎂 Ålder: {profile.age?.label}
        </Text>
        <Text style={styles.summaryDetail}>
          ⚽ Position: {profile.position?.name}
        </Text>
      </View>

      <View style={styles.readyContainer}>
        <Text style={styles.readyText}>
          🚀 Redo för din första lektion?
        </Text>
        <Text style={styles.readySubtext}>
          "Ditt Första Mål" - 3 minuter som förändrar allt!
        </Text>
      </View>

      <TouchableOpacity 
        style={styles.startButton}
        onPress={handleNext}
      >
        <Text style={styles.startButtonText}>⚡ Starta min fotbollsresa!</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <LinearGradient
      colors={['#2E8B57', '#228B22', '#1F5F3F']}
      style={styles.container}
    >
      {step === 1 && renderStep1()}
      {step === 2 && renderStep2()}
      {step === 3 && renderStep3()}
      {step === 4 && renderStep4()}
      
      {/* Progress indicator */}
      <View style={styles.progressContainer}>
        {[1, 2, 3, 4].map((stepNum) => (
          <View
            key={stepNum}
            style={[
              styles.progressDot,
              stepNum <= step && styles.progressDotActive
            ]}
          />
        ))}
      </View>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  stepContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    maxWidth: 400,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 20,
    color: 'rgba(255,255,255,0.9)',
    textAlign: 'center',
    marginBottom: 20,
  },
  description: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
    marginBottom: 40,
    lineHeight: 24,
  },
  inputContainer: {
    width: '100%',
    marginBottom: 30,
  },
  inputLabel: {
    fontSize: 18,
    color: 'white',
    marginBottom: 10,
    fontWeight: '600',
  },
  textInput: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 15,
    padding: 15,
    fontSize: 18,
    color: 'white',
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.3)',
  },
  optionsContainer: {
    width: '100%',
    gap: 15,
  },
  optionCard: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.3)',
  },
  optionCardSelected: {
    backgroundColor: 'rgba(255,255,255,0.3)',
    borderColor: 'white',
    transform: [{ scale: 1.05 }],
  },
  positionCard: {
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
    paddingHorizontal: 25,
  },
  optionEmoji: {
    fontSize: 40,
    marginBottom: 10,
  },
  optionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 5,
  },
  optionDescription: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
  },
  button: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 25,
    paddingVertical: 15,
    paddingHorizontal: 40,
    borderWidth: 2,
    borderColor: 'white',
    marginTop: 30,
  },
  buttonDisabled: {
    opacity: 0.5,
    borderColor: 'rgba(255,255,255,0.5)',
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  startButton: {
    backgroundColor: '#FFD700',
    borderRadius: 25,
    paddingVertical: 20,
    paddingHorizontal: 40,
    marginTop: 30,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  startButtonText: {
    color: '#2E8B57',
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  summaryContainer: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    width: '100%',
  },
  summaryText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 15,
  },
  summaryDetail: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.9)',
    marginBottom: 8,
  },
  readyContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  readyText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginBottom: 10,
  },
  readySubtext: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
    fontStyle: 'italic',
  },
  progressContainer: {
    flexDirection: 'row',
    position: 'absolute',
    bottom: 50,
    gap: 10,
  },
  progressDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: 'rgba(255,255,255,0.3)',
  },
  progressDotActive: {
    backgroundColor: 'white',
  },
});

export default OnboardingScreen;