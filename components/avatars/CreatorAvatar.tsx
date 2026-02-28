'use client';

import { motion } from 'framer-motion';

/** Creator — Exploding prism / building blocks */
export default function CreatorAvatar({ size = 120 }: { size?: number }) {
  const shards = [
    { points: '60,25 75,50 60,55 45,50', delay: 0 },
    { points: '45,50 60,55 50,80 30,65', delay: 0.3 },
    { points: '75,50 90,65 70,80 60,55', delay: 0.6 },
    { points: '50,80 60,55 70,80 60,95', delay: 0.9 },
  ];

  return (
    <motion.svg
      width={size}
      height={size}
      viewBox="0 0 120 120"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      whileHover={{ scale: 1.1, rotate: -10 }}
      transition={{ type: 'spring', stiffness: 200 }}
    >
      {/* Ambient glow */}
      <motion.circle
        cx="60"
        cy="60"
        r="40"
        fill="url(#creatorGlow)"
        animate={{ opacity: [0.2, 0.35, 0.2] }}
        transition={{ duration: 3, repeat: Infinity }}
      />

      {/* Prism shards */}
      {shards.map((shard, i) => (
        <motion.polygon
          key={i}
          points={shard.points}
          fill={`url(#creatorShard${i})`}
          stroke="#10B981"
          strokeWidth="1"
          animate={{
            opacity: [0.5, 1, 0.5],
            scale: [1, 1.03, 1],
          }}
          transition={{
            duration: 2.5,
            repeat: Infinity,
            delay: shard.delay,
            ease: 'easeInOut',
          }}
          style={{ transformOrigin: '60px 60px' }}
        />
      ))}

      {/* Sparkle particles */}
      {[
        { cx: 35, cy: 35 },
        { cx: 88, cy: 40 },
        { cx: 30, cy: 80 },
        { cx: 92, cy: 82 },
      ].map((p, i) => (
        <motion.circle
          key={i}
          cx={p.cx}
          cy={p.cy}
          r="1.5"
          fill="#10B981"
          animate={{
            opacity: [0, 1, 0],
            scale: [0.5, 1.5, 0.5],
          }}
          transition={{ duration: 2, repeat: Infinity, delay: i * 0.5 }}
        />
      ))}

      <defs>
        <radialGradient id="creatorGlow" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0%" stopColor="#10B981" stopOpacity="0.3" />
          <stop offset="100%" stopColor="#10B981" stopOpacity="0" />
        </radialGradient>
        {shards.map((_, i) => (
          <linearGradient key={i} id={`creatorShard${i}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#10B981" stopOpacity={0.6 + i * 0.1} />
            <stop offset="100%" stopColor="#059669" stopOpacity={0.2 + i * 0.05} />
          </linearGradient>
        ))}
      </defs>
    </motion.svg>
  );
}
