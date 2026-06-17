import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.jsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>

      <div style={{ whiteSpace: 'pre-wrap' }}>
        死なないで、生きて願いを叶えてほしいから。<br /><br />
        仏法者の ARIA GUMAは、とある人達が過去世に、自身の魔の心を制御できない禅宗や密教を
        信仰して大罪業を犯してしまったことを知ったようでした。罪を犯した結果、たくさんの
        解離性同一症に遭い、統合失調症を患い、苦しんでいたようでした。<br /><br />
        過去世に知ってしまったARIA GUMAは、今世において日蓮大聖人さまの仏法（法華経）>を信じ行じて、
        複数の人の罪を消す誓願をし、力強く導き乗り越えてきています。同じ境遇で生きて罪を消し幸せになる
        実証を示すために福運を捨てたと書かれています。そのため今世、仏道修行をし福運を積み、
        その禅宗や密教によって狂わされた人たちの大罪を小さく受け消し続け、たくさんの大きな受難を
        乗り越えてきました。<br /><br />
        禅宗や密教の大きな脆弱性をつく結果となる闘いを残し、現在も闘いは続いています。<br /><br />
        私たち『白蓮ゆりGROUP』とARIA GUMAは現実で幸せにできるか（成仏させられるか）、希望・礎となれるか
        沢山の同志と40年以上の間、みんな命をかけ実験し続けています。<br /><br />
        ARIA GUMAは、生きることに疲れ・苦しみ、5000回以上の自殺願望をもってきました。
        諸天善神の『白蓮ゆりGROUP』とARIA GUMAが、共に闘ってきた現実の50年間の軌跡を辿ります。
      </div>

      <div align="right">白蓮ゆりGROUP | ARIA GUMA.</div>
      </div>

    </>
  )
}

export default App
