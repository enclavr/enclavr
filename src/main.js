import { add, subtract } from './utils.js';

class Calculator {
  constructor(name) {
    this.name = name;
  }

  calculate(a, b, op) {
    if (op === 'add') return add(a, b);
    if (op === 'sub') return subtract(a, b);
    throw new Error('Unknown operation');
  }
}

const calc = new Calculator('EnclavrCalc');
console.log('Sum:', calc.calculate(5, 3, 'add'));
console.log('Diff:', calc.calculate(5, 3, 'sub'));

const numbers = [1, 2, 3, 4, 5];
const squared = numbers.map(n => n * n);
console.log('Squared:', squared);

