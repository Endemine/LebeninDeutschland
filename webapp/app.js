/**
 * Einbuergerungstest Pro - App
 * Komplette Single-Page App fuer den deutschen Einbuergerungstest
 * Vanilla JS, keine externen Bibliotheken
 */

// ============================================
// STATE MANAGEMENT
// ============================================

const app = window.app = {
  questions: [],       // Alle 460 Fragen
  currentScreen: 'home',
  darkMode: false,
  selectedState: 'Bayern',
  language: 'de',
  viewLanguage: localStorage.getItem('viewLanguage') || 'de', // de/en/ar für Fragen-Anzeige
  quiz: {
    questions: [],     // Aktuelle 33 Fragen
    currentIndex: 0,
    answers: {},       // { questionId: answerIndex }
    remainingSeconds: 3600,
    timerInterval: null,
    isRunning: false
  },
  progress: {
    learned: new Set(),      // Gelernte Fragen-IDs
    bookmarks: new Set(),    // Bookmarkte Fragen-IDs
    quizHistory: []          // { date, score, total, passed }
  }
};

// Übersetzungen sind direkt in jedem Frage-Objekt enthalten

// Globale Sprachumschaltfunktion
window.switchLang = function(lang) {
  app.viewLanguage = lang;
  localStorage.setItem('viewLanguage', lang);
  // Re-render aktuellen Screen mit neuem Sprachumschalter
  if (app.currentScreen === 'quiz') {
    createLangBar('quiz-main', 'quiz');
    showQuizQuestion(app.quiz.currentIndex);
  } else if (app.currentScreen === 'learn') {
    createLangBar('learn-main', 'learn');
    renderLearnQuestions();
  }
};

// Hilfsfunktionen für Übersetzungen
window.getQText = function(q) {
  const lang = app.viewLanguage;
  if (lang === 'de') return q.question;
  if (lang === 'en') return q.question_en || q.question;
  if (lang === 'ar') return q.question_ar || q.question;
  return q.question;
};

window.getAText = function(q, idx) {
  const lang = app.viewLanguage;
  if (lang === 'de') return q.answers[idx];
  if (lang === 'en') return (q.answers_en && q.answers_en[idx]) ? q.answers_en[idx] : q.answers[idx];
  if (lang === 'ar') return (q.answers_ar && q.answers_ar[idx]) ? q.answers_ar[idx] : q.answers[idx];
  return q.answers[idx];
};

// Kategorien-Mapping
const CATEGORIES = {
  'all': 'Alle',
  'Verfassung': 'Verfassung',
  'Geschichte': 'Geschichte',
  'Recht': 'Recht',
  'Gesellschaft': 'Gesellschaft',
  'Politik': 'Politik',
  'Wahl': 'Wahl',
  'Europa': 'Europa'
};

// Bundesland zu ID-Bereich Mapping (fuer Filterung der Bundesland-Fragen)
const STATE_ID_RANGES = {
  'Baden-Württemberg': [301, 310],
  'Bayern': [311, 320],
  'Berlin': [321, 330],
  'Brandenburg': [331, 340],
  'Bremen': [341, 350],
  'Hamburg': [351, 360],
  'Hessen': [361, 370],
  'Saarland': [371, 380],
  'Mecklenburg-Vorpommern': [381, 390],
  'Niedersachsen': [391, 400],
  'Nordrhein-Westfalen': [401, 410],
  'Rheinland-Pfalz': [411, 420],
  'Sachsen': [421, 440],
  'Sachsen-Anhalt': [421, 430], // Teilmenge von Sachsen-Bereich - fallback zu Text-Matching
  'Schleswig-Holstein': [441, 450],
  'Thüringen': [451, 460]
};

/**
 * Erkennt das Bundesland einer Frage anhand ID-Bereich oder Fragetext
 */
function getQuestionState(question) {
  // ID-Bereich Check
  for (const [state, range] of Object.entries(STATE_ID_RANGES)) {
    if (question.id >= range[0] && question.id <= range[1]) {
      // Spezialfall Sachsen-Anhalt vs Sachsen
      if (state === 'Sachsen' && question.id >= 431) continue;
      return state;
    }
  }
  // Fallback: Text-Matching
  const states = Object.keys(STATE_ID_RANGES);
  for (const s of states) {
    if (question.question.includes(s)) return s;
  }
  return null;
}

// ============================================
// LOCALSTORAGE
// ============================================

const STORAGE_KEYS = {
  PROGRESS: 'einbuergerung_progress',
  SETTINGS: 'einbuergerung_settings'
};

function loadFromStorage() {
  try {
    const settings = JSON.parse(localStorage.getItem(STORAGE_KEYS.SETTINGS));
    if (settings) {
      app.darkMode = settings.darkMode || false;
      app.selectedState = settings.selectedState || 'Bayern';
      app.language = settings.language || 'de';
    }

    const progress = JSON.parse(localStorage.getItem(STORAGE_KEYS.PROGRESS));
    if (progress) {
      app.progress.learned = new Set(progress.learned || []);
      app.progress.bookmarks = new Set(progress.bookmarks || []);
      app.progress.quizHistory = progress.quizHistory || [];
    }
  } catch (e) {
    console.warn('localStorage nicht verfuegbar:', e);
  }
}

function saveProgress() {
  try {
    const data = {
      learned: [...app.progress.learned],
      bookmarks: [...app.progress.bookmarks],
      quizHistory: app.progress.quizHistory
    };
    localStorage.setItem(STORAGE_KEYS.PROGRESS, JSON.stringify(data));
  } catch (e) {
    console.warn('Fortschritt konnte nicht gespeichert werden:', e);
  }
}

function saveSettings() {
  try {
    const data = {
      darkMode: app.darkMode,
      selectedState: app.selectedState,
      language: app.language
    };
    localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(data));
  } catch (e) {
    console.warn('Einstellungen konnten nicht gespeichert werden:', e);
  }
}

// ============================================
// UTILITY
// ============================================

function shuffleArray(arr) {
  const array = [...arr];
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

function formatTime(seconds) {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
}

function showToast(message) {
  const toast = document.getElementById('toast');
  const toastMessage = document.getElementById('toast-message');
  toastMessage.textContent = message;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2500);
}

// ============================================
// SCREEN NAVIGATION
// ============================================

function showScreen(screenId) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));

  let targetId;
  switch (screenId) {
    case 'home': targetId = 'screen-home'; break;
    case 'quiz': targetId = 'screen-quiz'; break;
    case 'result': targetId = 'screen-result'; break;
    case 'learn': targetId = 'screen-learn'; break;
    case 'statistics': targetId = 'screen-statistics'; break;
    case 'bookmarks': targetId = 'screen-bookmarks'; break;
    case 'settings': targetId = 'screen-settings'; break;
    default: targetId = 'screen-home';
  }

  const target = document.getElementById(targetId);
  if (target) {
    target.classList.add('active');
    app.currentScreen = screenId;
    window.scrollTo(0, 0);

    // Sprachumschalter dynamisch erstellen
    if (screenId === 'quiz') createLangBar('quiz-main', 'quiz');
    if (screenId === 'learn') createLangBar('learn-main', 'learn');

    // Screen-spezifische Initialisierungen
    if (screenId === 'learn') initLearnScreen();
    if (screenId === 'statistics') initStatsScreen();
    if (screenId === 'bookmarks') initBookmarksScreen();
    if (screenId === 'settings') initSettingsScreen();
  }
}

// Dynamisch Sprachumschalter erstellen
function createLangBar(containerId, screenType) {
  const container = document.getElementById(containerId);
  if (!container) return;
  // Entferne alten Umschalter
  const old = document.getElementById('lang-bar-' + screenType);
  if (old) old.remove();
  // Erstelle neuen Umschalter
  const bar = document.createElement('div');
  bar.id = 'lang-bar-' + screenType;
  bar.style.cssText = 'display:flex;justify-content:center;gap:10px;margin:12px auto;padding:10px;background:#FFF3E8;border-radius:12px;border:3px solid #FF6B00;max-width:280px;box-sizing:border-box;';
  const languages = [
    { code: 'de', label: 'DE', active: app.viewLanguage === 'de' },
    { code: 'en', label: 'EN', active: app.viewLanguage === 'en' },
    { code: 'ar', label: 'عربي', active: app.viewLanguage === 'ar' }
  ];
  languages.forEach(lang => {
    const btn = document.createElement('button');
    btn.textContent = lang.label;
    btn.style.cssText = lang.active
      ? 'padding:6px 18px;border:2px solid #FF6B00;border-radius:20px;background:#FF6B00;color:white;font-size:13px;font-weight:700;cursor:pointer;font-family:Inter,sans-serif;min-width:50px;text-align:center;'
      : 'padding:6px 18px;border:2px solid #FF6B00;border-radius:20px;background:white;color:#FF6B00;font-size:13px;font-weight:700;cursor:pointer;font-family:Inter,sans-serif;min-width:50px;text-align:center;';
    btn.addEventListener('click', function() {
      window.switchLang(lang.code);
    });
    bar.appendChild(btn);
  });
  container.insertBefore(bar, container.firstChild);
}

// ============================================
// DARK MODE
// ============================================

function toggleDarkMode() {
  app.darkMode = !app.darkMode;
  applyDarkMode();
  saveSettings();
}

function applyDarkMode() {
  if (app.darkMode) {
    document.documentElement.setAttribute('data-theme', 'dark');
  } else {
    document.documentElement.removeAttribute('data-theme');
  }
  // Sync toggle in settings
  const toggle = document.getElementById('settings-dark-mode');
  if (toggle) toggle.checked = app.darkMode;
}

// ============================================
// CONFIRM DIALOG
// ============================================

let dialogResolve = null;

function showDialog(title, message) {
  return new Promise(resolve => {
    dialogResolve = resolve;
    document.getElementById('dialog-title').textContent = title;
    document.getElementById('dialog-message').textContent = message;
    document.getElementById('dialog-overlay').classList.add('active');
  });
}

function hideDialog() {
  document.getElementById('dialog-overlay').classList.remove('active');
}

// ============================================
// DASHBOARD INITIALISIERUNG
// ============================================

function initDashboard() {
  // Dark Mode Button
  document.getElementById('btn-dark-mode').addEventListener('click', toggleDarkMode);

  // Bundesland Dropdown
  const bundeslandSelect = document.getElementById('bundesland-select');
  bundeslandSelect.value = app.selectedState;
  bundeslandSelect.addEventListener('change', e => {
    app.selectedState = e.target.value;
    document.getElementById('quiz-state-display').textContent = app.selectedState;
    saveSettings();
  });

  // Quiz Start Card
  document.getElementById('btn-start-quiz').addEventListener('click', startQuiz);

  // Menu Items
  document.querySelectorAll('.menu-item').forEach(item => {
    item.addEventListener('click', () => {
      const screen = item.dataset.screen;
      if (screen === 'quiz') {
        startQuiz();
      } else {
        showScreen(screen);
      }
    });
  });

  // Stats aktualisieren
  updateDashboardStats();
}

function updateDashboardStats() {
  document.getElementById('stat-learned').textContent = app.progress.learned.size;
  document.getElementById('stat-quizzes').textContent = app.progress.quizHistory.length;
  document.getElementById('quiz-state-display').textContent = app.selectedState;
}

// ============================================
// QUIZ LOGIC
// ============================================

function startQuiz() {
  if (app.questions.length === 0) {
    showToast('Fragen werden noch geladen...');
    return;
  }

  // 30 zufaellige allgemeine Fragen + 3 vom gewaehlten Bundesland
  const generalQuestions = app.questions.filter(q => q.category === 'Allgemein');
  const stateQuestions = app.questions.filter(q => {
    const qState = getQuestionState(q);
    return qState && qState === app.selectedState;
  });

  let selectedGeneral = shuffleArray(generalQuestions).slice(0, 30);
  let selectedState = [];

  if (stateQuestions.length >= 3) {
    selectedState = shuffleArray(stateQuestions).slice(0, 3);
  } else if (stateQuestions.length > 0) {
    selectedState = stateQuestions;
    // Auffuellen mit allgemeinen Fragen
    const remaining = 3 - selectedState.length;
    const usedIds = new Set([...selectedGeneral.map(q => q.id), ...selectedState.map(q => q.id)]);
    const extra = shuffleArray(generalQuestions.filter(q => !usedIds.has(q.id))).slice(0, remaining);
    selectedGeneral = selectedGeneral.slice(0, 30 - remaining);
    selectedState = [...selectedState, ...extra];
  } else {
    // Fallback: 33 allgemeine Fragen
    selectedGeneral = shuffleArray(generalQuestions).slice(0, 33);
  }

  app.quiz.questions = shuffleArray([...selectedGeneral, ...selectedState]);
  app.quiz.currentIndex = 0;
  app.quiz.answers = {};
  app.quiz.remainingSeconds = 3600;
  app.quiz.isRunning = true;

  showScreen('quiz');
  initQuizUI();
  startTimer();
}

function initQuizUI() {
  createLangBar('quiz-main', 'quiz');
  renderQuestionCircles();
  showQuizQuestion(0);
  updateTimerDisplay();
  updateProgressBar();

  // Button Event Listener
  document.getElementById('btn-quiz-prev').onclick = () => {
    if (app.quiz.currentIndex > 0) showQuizQuestion(app.quiz.currentIndex - 1);
  };

  document.getElementById('btn-quiz-next').onclick = () => {
    if (app.quiz.currentIndex < app.quiz.questions.length - 1) {
      showQuizQuestion(app.quiz.currentIndex + 1);
    } else {
      endQuiz();
    }
  };

  document.getElementById('btn-quit-quiz').onclick = () => {
    showDialog('Quiz beenden', 'Moechtest du das Quiz wirklich beenden? Dein Fortschritt wird gespeichert.')
      .then(confirmed => {
        if (confirmed) endQuiz();
      });
  };

  document.getElementById('btn-quiz-end').onclick = () => {
    showDialog('Test beenden', 'Moechtest du den Test jetzt beenden und dein Ergebnis sehen?')
      .then(confirmed => {
        if (confirmed) endQuiz();
      });
  };
}

function renderQuestionCircles() {
  const container = document.getElementById('question-circles');
  container.innerHTML = '';

  app.quiz.questions.forEach((q, i) => {
    const circle = document.createElement('button');
    circle.className = 'question-circle';
    circle.textContent = i + 1;
    circle.addEventListener('click', () => showQuizQuestion(i));
    container.appendChild(circle);
  });
}

function showQuizQuestion(index) {
  app.quiz.currentIndex = index;
  const question = app.quiz.questions[index];

  // Frage Nummer & Fortschritt
  document.getElementById('quiz-question-number').textContent = `Frage ${index + 1}`;
  document.getElementById('quiz-progress-text').textContent = `Frage ${index + 1} von ${app.quiz.questions.length}`;

  // Fragetext (übersetzt)
  document.getElementById('quiz-question-text').textContent = window.getQText(question);

  // RTL für Arabisch
  const questionCard = document.getElementById('quiz-question-card');
  if (app.viewLanguage === 'ar') {
    questionCard.setAttribute('dir', 'rtl');
  } else {
    questionCard.removeAttribute('dir');
  }

  // Antworten (übersetzt)
  const answersContainer = document.getElementById('quiz-answers');
  answersContainer.innerHTML = '';

  question.answers.forEach((_, i) => {
    const btn = document.createElement('button');
    btn.className = 'answer-btn';
    if (app.viewLanguage === 'ar') btn.setAttribute('dir', 'rtl');
    const letters = ['A', 'B', 'C', 'D'];
    btn.innerHTML = `
      <span class="answer-letter">${letters[i]}</span>
      <span class="answer-text">${window.getAText(question, i)}</span>
    `;

    // Bereits ausgewaehlt?
    if (app.quiz.answers[question.id] !== undefined) {
      const selected = app.quiz.answers[question.id];
      if (i === question.correct) {
        btn.classList.add('correct');
      } else if (i === selected && selected !== question.correct) {
        btn.classList.add('incorrect');
      }
      if (i === selected) btn.classList.add('selected');
    }

    btn.addEventListener('click', () => selectAnswer(i));
    answersContainer.appendChild(btn);
  });

  // Navigation Buttons
  document.getElementById('btn-quiz-prev').disabled = index === 0;

  const nextBtn = document.getElementById('btn-quiz-next');
  if (index === app.quiz.questions.length - 1) {
    nextBtn.innerHTML = `Ergebnis <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>`;
  } else {
    nextBtn.innerHTML = `Weiter <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>`;
  }

  // Kreise aktualisieren
  updateQuestionCircles();
  updateProgressBar();
}

function selectAnswer(answerIndex) {
  const question = app.quiz.questions[app.quiz.currentIndex];
  app.quiz.answers[question.id] = answerIndex;

  // Sofort Feedback
  const buttons = document.querySelectorAll('.answer-btn');
  buttons.forEach((btn, i) => {
    btn.classList.remove('selected', 'correct', 'incorrect');
    if (app.viewLanguage === 'ar') btn.setAttribute('dir', 'rtl');
    if (i === question.correct) {
      btn.classList.add('correct');
    } else if (i === answerIndex && answerIndex !== question.correct) {
      btn.classList.add('incorrect');
    }
    if (i === answerIndex) btn.classList.add('selected');
  });

  updateQuestionCircles();
  updateProgressBar();

  // Auto-weiter nach kurzer Pause
  setTimeout(() => {
    if (app.quiz.currentIndex < app.quiz.questions.length - 1) {
      showQuizQuestion(app.quiz.currentIndex + 1);
    }
  }, 500);
}

function updateQuestionCircles() {
  const circles = document.querySelectorAll('.question-circle');
  circles.forEach((circle, i) => {
    circle.classList.remove('current', 'answered', 'wrong');
    if (i === app.quiz.currentIndex) {
      circle.classList.add('current');
    }

    const question = app.quiz.questions[i];
    if (app.quiz.answers[question.id] !== undefined) {
      if (app.quiz.answers[question.id] === question.correct) {
        circle.classList.add('answered');
      } else {
        circle.classList.add('wrong');
      }
    }
  });
}

function updateProgressBar() {
  const answered = Object.keys(app.quiz.answers).length;
  const total = app.quiz.questions.length;
  const pct = total > 0 ? (answered / total) * 100 : 0;
  document.getElementById('quiz-progress-bar').style.width = pct + '%';
}

// ============================================
// TIMER
// ============================================

function startTimer() {
  if (app.quiz.timerInterval) clearInterval(app.quiz.timerInterval);

  app.quiz.timerInterval = setInterval(() => {
    app.quiz.remainingSeconds--;
    updateTimerDisplay();

    if (app.quiz.remainingSeconds <= 0) {
      clearInterval(app.quiz.timerInterval);
      showToast('Zeit abgelaufen!');
      endQuiz();
    }
  }, 1000);
}

function updateTimerDisplay() {
  const timerEl = document.getElementById('quiz-timer');
  timerEl.textContent = formatTime(app.quiz.remainingSeconds);

  const timerBar = document.getElementById('timer-bar');
  const pct = app.quiz.remainingSeconds / 3600 * 100;
  timerBar.style.width = pct + '%';

  if (app.quiz.remainingSeconds < 300) {
    timerEl.classList.add('warning');
    timerBar.classList.add('warning');
  } else {
    timerEl.classList.remove('warning');
    timerBar.classList.remove('warning');
  }
}

function stopTimer() {
  if (app.quiz.timerInterval) {
    clearInterval(app.quiz.timerInterval);
    app.quiz.timerInterval = null;
  }
}

// ============================================
// QUIZ ERGEBNIS
// ============================================

function endQuiz() {
  stopTimer();
  app.quiz.isRunning = false;

  let correct = 0;
  app.quiz.questions.forEach(q => {
    if (app.quiz.answers[q.id] === q.correct) correct++;
  });

  const passed = correct >= 17;

  // In Historie speichern
  app.progress.quizHistory.unshift({
    date: new Date().toISOString(),
    score: correct,
    total: app.quiz.questions.length,
    passed: passed
  });
  if (app.progress.quizHistory.length > 20) {
    app.progress.quizHistory = app.progress.quizHistory.slice(0, 20);
  }
  saveProgress();

  // Dashboard Stats aktualisieren
  updateDashboardStats();

  // Ergebnis anzeigen
  showResult(correct, passed);
}

function showResult(correct, passed) {
  showScreen('result');

  // Status
  const titleEl = document.getElementById('result-title');
  const subtitleEl = document.getElementById('result-subtitle');
  const iconEl = document.getElementById('result-icon');

  if (passed) {
    titleEl.textContent = 'Bestanden!';
    titleEl.className = 'result-title passed';
    subtitleEl.textContent = `Glueckwunsch! Du hast den Test mit ${correct}/33 Fragen bestanden.`;
    iconEl.textContent = '🎉';
    launchConfetti();
  } else {
    titleEl.textContent = 'Nicht bestanden';
    titleEl.className = 'result-title failed';
    subtitleEl.textContent = `Du hast ${correct}/33 Fragen richtig. Benoetigt werden mindestens 17.`;
    iconEl.textContent = '💪';
  }

  // Score
  document.getElementById('score-number').textContent = correct;

  // Kreis-Animation
  setTimeout(() => {
    const progress = document.getElementById('score-progress');
    const circumference = 339.292;
    const offset = circumference - (correct / 33) * circumference;
    progress.style.strokeDashoffset = offset;
  }, 300);

  // Antwortliste
  renderResultAnswers();

  // Buttons
  document.getElementById('btn-retry').onclick = startQuiz;
  document.getElementById('btn-result-home').onclick = () => showScreen('home');
  document.getElementById('btn-result-home-2').onclick = () => showScreen('home');
}

function renderResultAnswers() {
  const container = document.getElementById('result-answers-list');
  container.innerHTML = '';

  app.quiz.questions.forEach((q, i) => {
    const userAnswer = app.quiz.answers[q.id];
    const isCorrect = userAnswer === q.correct;
    const letters = ['A', 'B', 'C', 'D'];

    const item = document.createElement('div');
    item.className = 'result-answer-item ' + (isCorrect ? 'correct' : 'incorrect');
    if (app.viewLanguage === 'ar') item.setAttribute('dir', 'rtl');
    const translatedQuestion = window.getQText(q);
    const translatedUserAnswer = userAnswer !== undefined ? window.getAText(q, userAnswer) : '-';
    const translatedCorrectAnswer = window.getAText(q, q.correct);
    item.innerHTML = `
      <span class="result-answer-icon">${isCorrect ? '✅' : '❌'}</span>
      <span class="result-answer-text">
        <strong>Frage ${i + 1}:</strong> ${translatedQuestion}<br>
        <small>Deine Antwort: ${userAnswer !== undefined ? letters[userAnswer] : '-'} (${translatedUserAnswer}) | 
               Richtig: ${letters[q.correct]} (${translatedCorrectAnswer})</small>
      </span>
    `;
    container.appendChild(item);
  });
}

// ============================================
// CONFETTI
// ============================================

function launchConfetti() {
  const canvas = document.getElementById('confetti-canvas');
  const ctx = canvas.getContext('2d');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const colors = ['#FF6B00', '#FF8533', '#34C759', '#5856D6', '#FF9500', '#FF3B30', '#5AC8FA'];
  const particles = [];

  for (let i = 0; i < 120; i++) {
    particles.push({
      x: Math.random() * canvas.width,
      y: -20 - Math.random() * 200,
      vx: (Math.random() - 0.5) * 4,
      vy: 2 + Math.random() * 4,
      color: colors[Math.floor(Math.random() * colors.length)],
      size: 4 + Math.random() * 8,
      rotation: Math.random() * 360,
      rotSpeed: (Math.random() - 0.5) * 10
    });
  }

  let frame = 0;
  const maxFrames = 200;

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    particles.forEach(p => {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.05;
      p.rotation += p.rotSpeed;

      ctx.save();
      ctx.translate(p.x, p.y);
      ctx.rotate(p.rotation * Math.PI / 180);
      ctx.fillStyle = p.color;
      ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size);
      ctx.restore();
    });

    frame++;
    if (frame < maxFrames) requestAnimationFrame(draw);
    else ctx.clearRect(0, 0, canvas.width, canvas.height);
  }

  draw();
}

// ============================================
// LERN SCREEN
// ============================================

let learnFilter = 'all';
let learnSearch = '';
let expandedQuestions = new Set();

/**
 * Erkennt die Sub-Kategorie einer Allgemein-Frage anhand von Keywords
 */
function detectSubcategory(question) {
  const text = question.question.toLowerCase();
  const keywords = {
    'Verfassung': ['grundgesetz', 'verfassung', 'grundrecht', 'artikel', 'menschenwuerde', 'freiheit'],
    'Geschichte': ['geschichte', 'jahr', 'krieg', 'reich', 'ddr', 'hitler', '1945', '1918', '1989', 'mauer', 'wiedervereinigung', 'nationalsozialismus', 'drittes reich'],
    'Recht': ['gesetz', 'recht', 'gericht', 'straf', 'justiz', 'verboten', 'erlaubt', 'pflicht', 'bundesverfassungsgericht', 'polizei'],
    'Politik': ['politik', 'partei', 'regierung', 'bundestag', 'bundesrat', 'praesident', 'kanzler', 'minister', 'opposition'],
    'Wahl': ['wahl', 'waehlen', 'stimme', 'kandidat', 'urne', 'mandat'],
    'Europa': ['europa', 'eu ', 'europaeisch', 'europaeische union', 'euro', 'europaparlament']
  };

  const scores = {};
  for (const [cat, words] of Object.entries(keywords)) {
    let score = 0;
    for (const w of words) {
      if (text.includes(w)) score++;
    }
    if (score > 0) scores[cat] = score;
  }

  if (Object.keys(scores).length > 0) {
    return Object.entries(scores).sort((a, b) => b[1] - a[1])[0][0];
  }
  return 'Gesellschaft';
}

function initLearnScreen() {
  createLangBar('learn-main', 'learn');
  renderLearnQuestions();

  // Suchfeld
  const searchInput = document.getElementById('learn-search');
  searchInput.value = learnSearch;
  searchInput.oninput = e => {
    learnSearch = e.target.value.toLowerCase();
    renderLearnQuestions();
  };

  // Filter Tags
  document.querySelectorAll('.filter-tag').forEach(tag => {
    tag.onclick = () => {
      document.querySelectorAll('.filter-tag').forEach(t => t.classList.remove('active'));
      tag.classList.add('active');
      learnFilter = tag.dataset.category;
      renderLearnQuestions();
    };
  });
}

function renderLearnQuestions() {
  const container = document.getElementById('learn-questions-list');
  container.innerHTML = '';

  let filtered = app.questions.filter(q => {
    // Filter nach Kategorie
    if (learnFilter !== 'all') {
      // Hauptkategorien Allgemein und Bundesland
      if (learnFilter === 'Allgemein' || learnFilter === 'Bundesland') {
        if (q.category !== learnFilter) return false;
      } else {
        // Sub-Kategorien (nur fuer Allgemein-Fragen)
        if (q.category !== 'Allgemein') return false;
        const sub = detectSubcategory(q);
        if (sub !== learnFilter) return false;
      }
    }

    // Suche
    if (learnSearch) {
      const text = (q.question + ' ' + q.answers.join(' ')).toLowerCase();
      if (!text.includes(learnSearch)) return false;
    }
    return true;
  });

  if (filtered.length === 0) {
    container.innerHTML = '<div style="text-align:center;padding:40px;color:var(--text-secondary);">Keine Fragen gefunden.</div>';
    return;
  }

  filtered.forEach((q, idx) => {
    const isExpanded = expandedQuestions.has(q.id);
    const isLearned = app.progress.learned.has(q.id);
    const isBookmarked = app.progress.bookmarks.has(q.id);

    const item = document.createElement('div');
    item.className = 'learn-question-item';

    const letters = ['A', 'B', 'C', 'D'];

    let answersHtml = '';
    if (isExpanded) {
      const answered = item.dataset.answered === 'true';
      const selectedAnswer = parseInt(item.dataset.selectedAnswer || '-1');

      answersHtml = `<div class="learn-question-body expanded" ${app.viewLanguage === 'ar' ? 'dir="rtl"' : ''}>
        <div class="learn-answer-options">
          ${q.answers.map((_, i) => {
            let cls = '';
            if (selectedAnswer === i && i !== q.correct) cls = 'wrong';
            return `<button class="learn-answer-option ${cls}" data-idx="${i}" ${app.viewLanguage === 'ar' ? 'dir="rtl"' : ''}>
              <span class="answer-letter">${letters[i]}</span>
              <span>${window.getAText(q, i)}</span>
            </button>`;
          }).join('')}
        </div>
        <div class="learn-answer-feedback" id="feedback-${q.id}"></div>
      </div>`;
    }

    const translatedQuestion = window.getQText(q);
    item.innerHTML = `
      <button class="learn-question-header" onclick="toggleLearnQuestion(${q.id})" ${app.viewLanguage === 'ar' ? 'dir="rtl"' : ''}>
        <div class="learn-question-num ${isLearned ? 'learned' : ''}">${isLearned ? '✓' : q.id}</div>
        <div class="learn-question-content">
          <div class="learn-question-text">${translatedQuestion}</div>
          <div class="learn-question-meta">
            <span class="learn-question-category">${q.category === 'Allgemein' ? detectSubcategory(q) : (getQuestionState(q) || 'Bundesland')}</span>
          </div>
        </div>
        <div class="learn-question-actions" onclick="event.stopPropagation()">
          <button class="learn-action-btn ${isBookmarked ? 'bookmarked' : ''}" onclick="toggleBookmark(${q.id})" aria-label="Bookmark">
            <svg viewBox="0 0 24 24" fill="${isBookmarked ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2">
              <path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/>
            </svg>
          </button>
          <button class="learn-action-btn ${isLearned ? 'learned' : ''}" onclick="toggleLearned(${q.id})" aria-label="Gelernt">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 11l3 3L22 4"/>
              <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
            </svg>
          </button>
        </div>
      </button>
      ${answersHtml}
    `;

    // Antwort-Click-Handler wenn expanded
    if (isExpanded) {
      const body = item.querySelector('.learn-question-body');
      const feedback = item.querySelector(`#feedback-${q.id}`);

      item.querySelectorAll('.learn-answer-option').forEach((btn, i) => {
        btn.addEventListener('click', () => {
          // Sofort Feedback
          const buttons = item.querySelectorAll('.learn-answer-option');
          buttons.forEach((b, idx) => {
            b.classList.remove('correct', 'wrong');
            if (idx === q.correct) b.classList.add('correct');
            else if (idx === i && i !== q.correct) b.classList.add('wrong');
          });

          feedback.className = 'learn-answer-feedback show ' + (i === q.correct ? 'correct' : 'wrong');
          const feedbackCorrect = app.viewLanguage === 'ar' ? 'صحيح! 🎉' : (app.viewLanguage === 'en' ? 'Correct! 🎉' : 'Richtig! 🎉');
          const feedbackWrong = app.viewLanguage === 'ar' ? `خطأ. الجواب الصحيح هو: ${letters[q.correct]}` : (app.viewLanguage === 'en' ? `Wrong. The correct answer is: ${letters[q.correct]}` : `Falsch. Richtig waere: ${letters[q.correct]}`);
          feedback.textContent = i === q.correct ? feedbackCorrect : feedbackWrong;

          // Automatisch als gelernt markieren wenn richtig
          if (i === q.correct && !app.progress.learned.has(q.id)) {
            toggleLearned(q.id);
          }
        });
      });
    }

    container.appendChild(item);
  });
}

function toggleLearnQuestion(id) {
  if (expandedQuestions.has(id)) {
    expandedQuestions.delete(id);
  } else {
    expandedQuestions.add(id);
  }
  renderLearnQuestions();
}

function toggleBookmark(id) {
  if (app.progress.bookmarks.has(id)) {
    app.progress.bookmarks.delete(id);
    showToast('Bookmark entfernt');
  } else {
    app.progress.bookmarks.add(id);
    showToast('Bookmark hinzugefuegt');
  }
  saveProgress();
  renderLearnQuestions();
}

function toggleLearned(id) {
  if (app.progress.learned.has(id)) {
    app.progress.learned.delete(id);
    showToast('Als ungelernt markiert');
  } else {
    app.progress.learned.add(id);
    showToast('Als gelernt markiert');
  }
  saveProgress();
  renderLearnQuestions();
  updateDashboardStats();
}

// ============================================
// STATISTIKEN SCREEN
// ============================================

function initStatsScreen() {
  // Kreis-Fortschritt
  const total = app.questions.length || 460;
  const learned = app.progress.learned.size;
  const pct = total > 0 ? Math.round((learned / total) * 100) : 0;

  document.getElementById('stats-circle-number').textContent = pct;
  document.getElementById('stats-learned-count').textContent = learned;
  document.getElementById('stats-total-count').textContent = total;

  const circumference = 339.292;
  const offset = circumference - (pct / 100) * circumference;
  document.getElementById('stats-progress-circle').style.strokeDashoffset = offset;

  // Kategorien-Balken
  renderCategoryBars();

  // Quiz-Historie
  renderQuizHistory();

  // Erfolgsrate
  renderSuccessRate();
}

function renderCategoryBars() {
  const container = document.getElementById('stats-category-bars');
  container.innerHTML = '';

  // Sub-Kategorien zaehlen
  const catCounts = {};
  const catLearned = {};

  app.questions.forEach(q => {
    let cat;
    if (q.category === 'Bundesland') {
      cat = getQuestionState(q) || 'Bundesland';
    } else {
      cat = detectSubcategory(q);
    }
    catCounts[cat] = (catCounts[cat] || 0) + 1;
    if (app.progress.learned.has(q.id)) {
      catLearned[cat] = (catLearned[cat] || 0) + 1;
    }
  });

  Object.entries(catCounts).sort((a, b) => b[1] - a[1]).forEach(([cat, total]) => {
    const learned = catLearned[cat] || 0;
    const pct = Math.round((learned / total) * 100);

    const item = document.createElement('div');
    item.className = 'category-bar-item';
    item.innerHTML = `
      <div class="category-bar-header">
        <span class="category-bar-name">${cat}</span>
        <span class="category-bar-value">${learned}/${total}</span>
      </div>
      <div class="category-bar-track">
        <div class="category-bar-fill" style="width: ${pct}%"></div>
      </div>
    `;
    container.appendChild(item);
  });
}

function renderQuizHistory() {
  const container = document.getElementById('stats-history-list');
  container.innerHTML = '';

  if (app.progress.quizHistory.length === 0) {
    container.innerHTML = '<div style="text-align:center;padding:20px;color:var(--text-secondary);font-size:0.875rem;">Noch keine Quizze absolviert.</div>';
    return;
  }

  app.progress.quizHistory.slice(0, 10).forEach(entry => {
    const date = new Date(entry.date);
    const dateStr = date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
    const timeStr = date.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });

    const item = document.createElement('div');
    item.className = 'history-item';
    item.innerHTML = `
      <div class="history-score ${entry.passed ? 'passed' : 'failed'}">${entry.score}/${entry.total}</div>
      <div class="history-info">
        <div class="history-date">${dateStr} - ${timeStr}</div>
        <div class="history-detail">${entry.passed ? 'Bestanden' : 'Nicht bestanden'}</div>
      </div>
      <span class="history-badge ${entry.passed ? 'passed' : 'failed'}">${entry.passed ? '✓' : '✗'}</span>
    `;
    container.appendChild(item);
  });
}

function renderSuccessRate() {
  const history = app.progress.quizHistory;
  if (history.length === 0) {
    document.getElementById('rate-number').textContent = '0%';
    document.getElementById('rate-bar').style.width = '0%';
    document.getElementById('rate-detail').textContent = '0 von 0 Quizzen bestanden';
    return;
  }

  const passed = history.filter(h => h.passed).length;
  const pct = Math.round((passed / history.length) * 100);

  document.getElementById('rate-number').textContent = pct + '%';
  document.getElementById('rate-bar').style.width = pct + '%';
  document.getElementById('rate-detail').textContent = `${passed} von ${history.length} Quizzen bestanden`;
}

// ============================================
// BOOKMARKS SCREEN
// ============================================

function initBookmarksScreen() {
  const container = document.getElementById('bookmarks-list');
  const emptyEl = document.getElementById('bookmarks-empty');
  container.innerHTML = '';

  const bookmarkedQuestions = app.questions.filter(q => app.progress.bookmarks.has(q.id));

  if (bookmarkedQuestions.length === 0) {
    emptyEl.classList.add('show');
    return;
  }

  emptyEl.classList.remove('show');

  bookmarkedQuestions.forEach(q => {
    const isLearned = app.progress.learned.has(q.id);
    const translatedQuestion = window.getQText(q);
    const item = document.createElement('div');
    item.className = 'learn-question-item';
    if (app.viewLanguage === 'ar') item.setAttribute('dir', 'rtl');
    item.innerHTML = `
      <div class="learn-question-header" ${app.viewLanguage === 'ar' ? 'dir="rtl"' : ''}>
        <div class="learn-question-num ${isLearned ? 'learned' : ''}">${isLearned ? '✓' : q.id}</div>
        <div class="learn-question-content">
          <div class="learn-question-text">${translatedQuestion}</div>
          <div class="learn-question-meta">
            <span class="learn-question-category">${q.category === 'Allgemein' ? detectSubcategory(q) : (getQuestionState(q) || 'Bundesland')}</span>
          </div>
        </div>
        <div class="learn-question-actions">
          <button class="learn-action-btn bookmarked" onclick="toggleBookmark(${q.id})" aria-label="Bookmark entfernen">
            <svg viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2">
              <path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/>
            </svg>
          </button>
        </div>
      </div>
    `;
    container.appendChild(item);
  });
}

// ============================================
// EINSTELLUNGEN SCREEN
// ============================================

function initSettingsScreen() {
  // Bundesland
  const bundeslandSelect = document.getElementById('settings-bundesland');
  bundeslandSelect.value = app.selectedState;
  bundeslandSelect.onchange = e => {
    app.selectedState = e.target.value;
    document.getElementById('bundesland-select').value = app.selectedState;
    document.getElementById('quiz-state-display').textContent = app.selectedState;
    saveSettings();
    showToast('Bundesland aktualisiert');
  };

  // Dark Mode
  const darkModeToggle = document.getElementById('settings-dark-mode');
  darkModeToggle.checked = app.darkMode;
  darkModeToggle.onchange = () => {
    toggleDarkMode();
  };

  // Sprache
  const langSelect = document.getElementById('settings-language');
  langSelect.value = app.language;
  langSelect.onchange = e => {
    app.language = e.target.value;
    saveSettings();
    showToast('Sprache geaendert (neu laden erforderlich)');
  };

  // Fortschritt zuruecksetzen
  document.getElementById('btn-reset-progress').onclick = () => {
    showDialog('Fortschritt zuruecksetzen', 'Bist du sicher? Alle Lernfortschritte und Statistiken werden geloescht.')
      .then(confirmed => {
        if (confirmed) {
          app.progress.learned = new Set();
          app.progress.bookmarks = new Set();
          app.progress.quizHistory = [];
          saveProgress();
          updateDashboardStats();
          showToast('Fortschritt zurueckgesetzt');
        }
      });
  };
}

// ============================================
// DIALOG HANDLER
// ============================================

document.getElementById('dialog-confirm').addEventListener('click', () => {
  hideDialog();
  if (dialogResolve) dialogResolve(true);
});

document.getElementById('dialog-cancel').addEventListener('click', () => {
  hideDialog();
  if (dialogResolve) dialogResolve(false);
});

document.getElementById('dialog-overlay').addEventListener('click', e => {
  if (e.target === document.getElementById('dialog-overlay')) {
    hideDialog();
    if (dialogResolve) dialogResolve(false);
  }
});

// ============================================
// BACK BUTTONS
// ============================================

document.querySelectorAll('.btn-back').forEach(btn => {
  btn.addEventListener('click', () => {
    showScreen(btn.dataset.screen);
  });
});

// ============================================
// DATA LOADING & INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  // Einstellungen laden
  loadFromStorage();
  applyDarkMode();

  // Fragen laden (mit Cache-Buster)
  fetch('questions.json?v=' + Date.now())
    .then(r => {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    })
    .then(questions => {
      app.questions = questions;
      console.log('Fragen geladen:', questions.length);
      console.log('Q1 EN:', questions[0].question_en ? 'vorhanden' : 'fehlt');

      // Loading Screen ausblenden und Home anzeigen
      const loadingScreen = document.getElementById('loading-screen');
      if (loadingScreen) loadingScreen.classList.remove('active');
      showScreen('home');
      initDashboard();
    })
    .catch(err => {
      console.error('Fehler beim Laden der Fragen:', err);
      document.querySelector('.loading-text').textContent = 'Fehler beim Laden der Fragen. Bitte Seite neu laden.';
      document.querySelector('.loading-spinner').style.borderColor = 'var(--error)';
      document.querySelector('.loading-spinner').style.borderTopColor = 'var(--error)';
    });
});

// Service Worker fuer PWA
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('sw.js').catch(() => {
    // Service Worker optional
  });
}