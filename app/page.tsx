import { slugify } from "../lib/slugify";

export default function Home() {
  return (
    <main>
      <h1>It works</h1>
      <p>
        Replace this page with your app. The slug of this page title is <code>{slugify("It works")}</code>.
      </p>
    </main>
  );
}
