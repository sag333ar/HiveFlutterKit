import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)} style={{
      position: 'relative',
      width: '100vw',
      minHeight: '60vh',
      marginLeft: 'calc(50% - 50vw)',
      marginRight: 'calc(50% - 50vw)',
      padding: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      overflow: 'hidden',
    }}>
      <div style={{
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        backgroundImage: 'url(https://github.com/sag333ar/HiveFlutterKit/raw/main/assets/images/banner.jpg?raw=true)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat',
        opacity: 0.05,
        zIndex: 0,
      }} />
      <div className="container" style={{
        position: 'relative',
        zIndex: 1,
        borderRadius: '12px',
        padding: '2rem 0',
        width: '100%',
        maxWidth: '900px',
        margin: '0 auto',
      }}>
        <div className="text--center">
          <img
            src={
              "https://hiveflutterkit.sagarkothari88.one/img/hiveflutterkit_logo.png"
            }
            alt={"Hive Flutter Kit Logo"}
            width={75}
            height={75}
          />
        </div>
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
          >
            View Docs
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="Description will go into a meta tag in <head />"
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
