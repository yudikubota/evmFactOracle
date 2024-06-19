
export function NumberToFactor(num: number, decimal: number) {
    if (num && decimal) 
      return Math.round(num * Math.pow(10, decimal));
    else 
      return num;
  }
  
  export function NumberFromFactor(num: number, decimal: number) {
    if (num && decimal) 
      return Math.round(num / Math.pow(10, decimal));
    else 
      return num;
  }

