import * as styles from "./vector-map-style/styles";
import { writeFileSync } from "fs";

Object.keys(styles).forEach((key) => {
  const style = styles[key];
  writeFileSync(`${key}.json`, JSON.stringify(style));
  console.log(`Wrote ${key}.json`);
});
