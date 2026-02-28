export interface Agent {
  name: string;
  nickname: string;
  emoji: string;
  role: string;
  description: string;
  accent: string;
  primary: string;
  cardBg: string;
  gradientFrom: string;
  gradientTo: string;
  image: string;
}

// Order: Popo (Admin), Tyler (Creator), Kanye (Thinker), Rocky (Gatekeeper)
export const agents: Agent[] = [
  {
    name: 'Popo',
    nickname: 'Admin',
    emoji: '\u{1F693}',
    role: 'Coordinator',
    description: 'Orchestrates the team. Assigns tasks, coordinates handoffs, keeps the rhythm.',
    primary: '#3A4F7A',
    accent: '#8B7D5C',
    cardBg: '#1a2a3a',
    gradientFrom: '#0D1520',
    gradientTo: '#1A2A42',
    image: '/images/agents/admin.png',
  },
  {
    name: 'Tyler',
    nickname: 'Creator',
    emoji: '\u{1F3A8}',
    role: 'Builder',
    description: 'Turns specs into reality. Code, design, implementation \u2014 every pixel, every line.',
    primary: '#C49A1A',
    accent: '#D4A843',
    cardBg: '#1e1a10',
    gradientFrom: '#141210',
    gradientTo: '#2A2418',
    image: '/images/agents/creator.png',
  },
  {
    name: 'Kanye',
    nickname: 'Thinker',
    emoji: '\u{1F9E0}',
    role: 'Researcher',
    description: "Goes deep on problems. Research, analysis, specs \u2014 the team's brain and strategist.",
    primary: '#E8E0D0',
    accent: '#C8A84E',
    cardBg: '#2a2824',
    gradientFrom: '#1A1918',
    gradientTo: '#2A2824',
    image: '/images/agents/thinker.png',
  },
  {
    name: 'Rocky',
    nickname: 'Gatekeeper',
    emoji: '\u{1F6E1}',
    role: 'Reviewer',
    description: 'Quality control. Every deliverable passes through before shipping. Nothing slips by.',
    primary: '#D4940C',
    accent: '#E8A020',
    cardBg: '#2a1e08',
    gradientFrom: '#1A1408',
    gradientTo: '#2A2210',
    image: '/images/agents/gatekeeper.png',
  },
];

export const pipelineSteps = [
  { label: 'Think', image: '/images/pipeline/think.png', agent: 'Thinker' },
  { label: 'Build', image: '/images/pipeline/build.png', agent: 'Creator' },
  { label: 'Check', image: '/images/pipeline/check.png', agent: 'Gatekeeper' },
  { label: 'Ship',  image: '/images/pipeline/ship.png',  agent: 'Admin' },
];

export const terminalContent = `# Task Handoff

- **From:** Thinker \u{1F9E0}
- **To:** Creator \u{1F3A8}
- **Priority:** urgent

## Task
Build the landing page from v7 spec

## Context
Design reference: microsoft.ai
Stack: Next.js 14 + Tailwind + Framer Motion`;
