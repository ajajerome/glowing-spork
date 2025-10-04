import React from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView,
  TouchableOpacity,
  Dimensions 
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');

// Foundation-first progress screen - Duolingo-inspired achievement system
const ProgressScreen = ({ userProfile, onNavigate }) => {
  
  // Mock progress data (in real app, this comes from AsyncStorage/backend)
  const progressData = {
    currentLevel: 1,
    totalXP: userProfile?.xp || 150,
    streak: 1,
    badges: [
      { id: 'first_goal', name: 'Första Mål', emoji: '⚽', earned: true },
      { id: 'team_player', name: 'Team Player', emoji: '🤝', earned: true },
      { id: 'defender', name: 'Vägg', emoji: '🛡️', earned: true },
      { id: 'streak_3', name: '3 Dagars Streak', emoji: '🔥', earned: false },
      { id: 'level_2', name: 'Level 2', emoji: '🏆', earned: false },
    ],
    skillProgress: {
      'Spatial Awareness': 80,
      'Teamwork': 75,
      'Defensive Positioning': 70,
      'Passing': 20,
      'Shooting': 60,
    },
    weeklyGoal: {
      current: 3,
      target: 7,
      description: 'Lektioner denna vecka'
    }
  };

  const getLevelProgress = () => {
    const currentLevelXP = progressData.totalXP % 100;
    const nextLevelXP = 100;
    return (currentLevelXP / nextLevelXP) * 100;
  };

  const renderSkillBar = (skill, progress) => (
    <View key={skill} style={styles.skillContainer}>
      <Text style={styles.skillName}>{skill}</Text>
      <View style={styles.skillBarBackground}>
        <View 
          style={[
            styles.skillBarFill, 
            { width: `${progress}%` }
          ]} 
        />
      </View>
      <Text style={styles.skillPercentage}>{progress}%</Text>
    </View>
  );

  const renderBadge = (badge) => (
    <View 
      key={badge.id} 
      style={[
        styles.badgeContainer,
        !badge.earned && styles.badgeNotEarned
      ]}
    >
      <Text style={[
        styles.badgeEmoji,
        !badge.earned && styles.badgeEmojiGray
      ]}>
        {badge.emoji}
      </Text>
      <Text style={[
        styles.badgeName,
        !badge.earned && styles.badgeNameGray
      ]}>
        {badge.name}
      </Text>
    </View>
  );

  return (
    <LinearGradient
      colors={['#1F5F3F', '#2E8B57', '#228B22']}
      style={styles.container}
    >
      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity 
            style={styles.backButton}
            onPress={() => onNavigate('lesson')}
          >
            <Text style={styles.backButtonText}>← Tillbaka</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Din Fotbollsresa</Text>
        </View>

        {/* Player Profile Card */}
        <View style={styles.profileCard}>
          <View style={styles.profileHeader}>
            <View style={styles.avatarContainer}>
              <Text style={styles.avatarEmoji}>
                {userProfile?.position?.emoji || '⚽'}
              </Text>
            </View>
            <View style={styles.profileInfo}>
              <Text style={styles.playerName}>{userProfile?.name || 'Spelare'}</Text>
              <Text style={styles.playerDetails}>
                {userProfile?.age?.label} • {userProfile?.position?.name}
              </Text>
            </View>
          </View>
          
          {/* Level Progress */}
          <View style={styles.levelContainer}>
            <Text style={styles.levelText}>Level {progressData.currentLevel}</Text>
            <View style={styles.levelProgressBar}>
              <View 
                style={[
                  styles.levelProgressFill, 
                  { width: `${getLevelProgress()}%` }
                ]} 
              />
            </View>
            <Text style={styles.xpText}>{progressData.totalXP} XP</Text>
          </View>
        </View>

        {/* Daily Streak */}
        <View style={styles.streakCard}>
          <Text style={styles.streakTitle}>🔥 Daglig Streak</Text>
          <Text style={styles.streakNumber}>{progressData.streak} dag</Text>
          <Text style={styles.streakDescription}>
            Fortsätt träna varje dag för att bygga din streak!
          </Text>
        </View>

        {/* Weekly Goal */}
        <View style={styles.goalCard}>
          <Text style={styles.goalTitle}>🎯 Veckans Mål</Text>
          <View style={styles.goalProgress}>
            <View style={styles.goalProgressBar}>
              <View 
                style={[
                  styles.goalProgressFill,
                  { width: `${(progressData.weeklyGoal.current / progressData.weeklyGoal.target) * 100}%` }
                ]}
              />
            </View>
            <Text style={styles.goalText}>
              {progressData.weeklyGoal.current} / {progressData.weeklyGoal.target} {progressData.weeklyGoal.description}
            </Text>
          </View>
        </View>

        {/* Skills Progress */}
        <View style={styles.skillsCard}>
          <Text style={styles.cardTitle}>📊 Dina Färdigheter</Text>
          {Object.entries(progressData.skillProgress).map(([skill, progress]) =>
            renderSkillBar(skill, progress)
          )}
        </View>

        {/* Badges Collection */}
        <View style={styles.badgesCard}>
          <Text style={styles.cardTitle}>🏅 Dina Badges</Text>
          <View style={styles.badgesGrid}>
            {progressData.badges.map(renderBadge)}
          </View>
        </View>

        {/* Continue Learning Button */}
        <TouchableOpacity 
          style={styles.continueButton}
          onPress={() => onNavigate('lesson')}
        >
          <LinearGradient
            colors={['#FFD700', '#FFA500']}
            style={styles.continueButtonGradient}
          >
            <Text style={styles.continueButtonText}>
              ⚡ Fortsätt Lära Dig!
            </Text>
          </LinearGradient>
        </TouchableOpacity>

        <View style={styles.bottomSpacing} />
      </ScrollView>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 20,
  },
  backButton: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 20,
    paddingHorizontal: 15,
    paddingVertical: 8,
  },
  backButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  headerTitle: {
    flex: 1,
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
    marginLeft: -80, // Compensate for back button
  },
  profileCard: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 20,
    padding: 20,
  },
  profileHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  avatarContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(255,215,0,0.3)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  avatarEmoji: {
    fontSize: 30,
  },
  profileInfo: {
    flex: 1,
  },
  playerName: {
    fontSize: 22,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 5,
  },
  playerDetails: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.8)',
  },
  levelContainer: {
    alignItems: 'center',
  },
  levelText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
  },
  levelProgressBar: {
    width: '100%',
    height: 12,
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 6,
    marginBottom: 8,
  },
  levelProgressFill: {
    height: '100%',
    backgroundColor: '#FFD700',
    borderRadius: 6,
  },
  xpText: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.9)',
    fontWeight: '600',
  },
  streakCard: {
    backgroundColor: 'rgba(255,107,53,0.2)',
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'rgba(255,107,53,0.4)',
  },
  streakTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 10,
  },
  streakNumber: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#FF6B35',
    marginBottom: 10,
  },
  streakDescription: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
  },
  goalCard: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 20,
    padding: 20,
  },
  goalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 15,
  },
  goalProgress: {
    alignItems: 'center',
  },
  goalProgressBar: {
    width: '100%',
    height: 10,
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 5,
    marginBottom: 10,
  },
  goalProgressFill: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 5,
  },
  goalText: {
    fontSize: 16,
    color: 'rgba(255,255,255,0.9)',
    fontWeight: '500',
  },
  skillsCard: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 20,
    padding: 20,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 15,
  },
  skillContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  skillName: {
    flex: 1,
    fontSize: 14,
    color: 'rgba(255,255,255,0.9)',
    fontWeight: '500',
  },
  skillBarBackground: {
    flex: 2,
    height: 8,
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 4,
    marginHorizontal: 10,
  },
  skillBarFill: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 4,
  },
  skillPercentage: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.8)',
    fontWeight: '600',
    minWidth: 35,
    textAlign: 'right',
  },
  badgesCard: {
    backgroundColor: 'rgba(255,255,255,0.15)',
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 20,
    padding: 20,
  },
  badgesGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  badgeContainer: {
    width: (width - 80) / 3,
    backgroundColor: 'rgba(255,215,0,0.2)',
    borderRadius: 15,
    padding: 15,
    alignItems: 'center',
    marginBottom: 15,
    borderWidth: 2,
    borderColor: 'rgba(255,215,0,0.4)',
  },
  badgeNotEarned: {
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderColor: 'rgba(255,255,255,0.2)',
  },
  badgeEmoji: {
    fontSize: 24,
    marginBottom: 8,
  },
  badgeEmojiGray: {
    opacity: 0.3,
  },
  badgeName: {
    fontSize: 12,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
  },
  badgeNameGray: {
    color: 'rgba(255,255,255,0.4)',
  },
  continueButton: {
    marginHorizontal: 20,
    marginBottom: 20,
    borderRadius: 25,
    overflow: 'hidden',
  },
  continueButtonGradient: {
    paddingVertical: 18,
    paddingHorizontal: 30,
    alignItems: 'center',
  },
  continueButtonText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2E8B57',
  },
  bottomSpacing: {
    height: 50,
  },
});

export default ProgressScreen;