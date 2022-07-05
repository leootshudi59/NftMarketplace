import "../styles/style.css";
import Link from "next/link";
import { useRef } from "react";

function MyApp({ Component, pageProps }) {
  const clickPoint = useRef();

  return (
    <div>
      <nav className="flex grow justify-center items-center max-w-full h-24 px-16">
        <div className="flex grow inset-x-0 content-center items-center justify-between">
          <div className="items-center">
            <div className="relative mr-3">
              <div className="absolute top-3 left-3 items-center" ref={clickPoint}>
                <svg
                  className="w-5 h-5 text-gray-500"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fillRule="evenodd"
                    d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                    clipRule="evenodd"
                  ></path>
                </svg>
              </div>
              <input type="text" className="block p-2 pl-10 w-70 text-gray-900 bg-gray-50 rounded-lg border border-gray-300" placeholder="Search Here..." />
            </div>
          </div>
          <Link href="/">
            <a className="items-center">Home</a>
          </Link>
          <Link href="/create-item">
            <a className="items-center text-pink-500">Sell</a>
          </Link>
          <Link href="/my-assets">
            <a className="items-center">My digital assets</a>
          </Link>
          <Link href="/creator-dashboard">
            <a className="items-center">Creator dashboard</a>
          </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  );
}

export default MyApp;
