'use client';

import { motion } from 'framer-motion';

/** Thinker — Neural nebula cluster */
export default function ThinkerAvatar({ size = 120 }: { size?: number }) {
  const nodes = [
    { cx: 60, cy: 35, r: 4 },
    { cx: 40, cy: 55, r: 3 },
    { cx: 80, cy: 55, r: 3 },
    { cx: 35, cy: 75, r: 2.5 },
    { cx: 60, cy: 75, r: 3.5 },
    { cx: 85, cy: 75, r: 2.5 },
    { cx: 50, cy: 45, r: 2 },
    { cx: 70, cy: 45, r: 2 },
  ];

  const connections = [
    [0, 1], [0, 2], [0, 6], [0, 7],
    [1, 3], [1, 4], [1, 6],
    [2, 4], [2, 5], [2, 7],
    [3, 4], [4, 5],
    [6, 7],
  ];

  return (
    <motion.svg
      width={size}
      height={size}
      viewBox="0 0 120 120"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      whileHover={{ scale: 1.1 }}
      transition={{ type: 'spring', stiffness: 200 }}
    >
      {/* Ambient glow */}
      <motion.circle
        cx="60"
        cy="60"
        r="45"
        fill="url(#thinkerGlow)"
        animate={{ opacity: [0.2, 0.4, 0.2], scale: [1, 1.05, 1] }}
        transition={{ duration: 4, repeat: Infinity }}
      />

      {/* Connections */}
      {connections.map(([a, b], i) => (
        <motion.line
          key={i}
          x1={nodes[a].cx}
          y1={nodes[a].cy}
          x2={nodes[b].cx}
          y2={nodes[b].cy}
          stroke="#8B5CF6"
          strokeWidth="1"
          animate={{ opacity: [0.15, 0.5, 0.15] }}
          transition={{ duration: 2 + (i % 3) * 0.5, repeat: Infinity, delay: i * 0.15 }}
        />
      ))}

      {/* Nodes */}
      {nodes.map((node, i) => (
        <motion.circle
          key={i}
          cx={node.cx}
          cy={node.cy}
          r={node.r}
          fill="#8B5CF6"
          animate={{
            r: [node.r, node.r + 1.5, node.r],
            opacity: [0.6, 1, 0.6],
          }}
          transition={{ duration: 2 + i * 0.3, repeat: Infinity, ease: 'easeInOut' }}
        />
      ))}

      {/* Central brain pulse */}
      <motion.circle
        cx="60"
        cy="55"
        r="8"
        fill="none"
        stroke="#8B5CF6"
        strokeWidth="1.5"
        animate={{ r: [8, 14, 8], opacity: [0.6, 0, 0.6] }}
        transition={{ duration: 2.5, repeat: Infinity }}
      />

      <defs>
        <radialGradient id="thinkerGlow" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0%" stopColor="#8B5CF6" stopOpacity="0.3" />
          <stop offset="100%" stopColor="#8B5CF6" stopOpacity="0" />
        </radialGradient>
      </defs>
    </motion.svg>
  );
}
