import assert from 'node:assert';
import { add, subtract } from '../src/utils.js';

console.log('Running tests...');
assert.strictEqual(add(2, 3), 5);
assert.strictEqual(subtract(5, 2), 3);
console.log('All tests passed!');
